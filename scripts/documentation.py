#!/usr/bin/env python3
"""Validate canonical documentation facts and derive disposable navigation."""
from __future__ import annotations

import argparse
import csv
import hashlib
import importlib.util
import json
import pathlib
import re
import sys
from urllib.parse import unquote, urlsplit

# Trace: DOC-MAINTENANCE-001. These checks establish structure, not product Pass.

ROOT = pathlib.Path(__file__).resolve().parents[1]
REQUIREMENTS = 'docs/requirements/'
PROJECT = 'docs/project/'
SOURCES = [REQUIREMENTS + name for name in (
    'training-simulation-initial-requirements.md',
    'training-simulation-non-functional-requirements.md',
    'training-simulation-performance-assessment-requirements.md',
    'training-simulation-performance-profile-engagement-target-001.md',
    'training-simulation-verification-plan.md',
    'training-simulation-autonomous-participant-requirements.md',
    'domain-evaluation.md',
)] + [PROJECT + 'documentation-policy.md']
APPLICABILITY = REQUIREMENTS + 'training-simulation-baseline-applicability-inventory.csv'
EXAMPLES = REQUIREMENTS + 'training-simulation-acceptance-examples.csv'
MIGRATION = PROJECT + 'documentation-migration.csv'
CLAIMS = PROJECT + 'training-simulation-architecture-claim-traces.csv'
COMMITMENTS = 'docs/design/training-simulation-design-commitments.csv'
ID = r'[A-Z][A-Z0-9-]+-[0-9]{3}'
DEFINITION = re.compile(rf'^(?:- )?\*\*({ID})\*\*', re.MULTILINE)
LINK = re.compile(r'!?\[[^\]\n]*\]\((<[^>]+>|[^\s)]+)(?:\s+"[^"]*")?\)')


def rows(root: pathlib.Path, path: str) -> list[dict[str, str]]:
    with (root / path).open(newline='') as stream:
        result = list(csv.DictReader(stream))
    if not result or any(None in row or any(v is None for v in row.values()) for row in result):
        raise ValueError(f'Empty or malformed CSV: {path}')
    return result


def keyed(records: list[dict[str, str]], field: str) -> dict[str, dict[str, str]]:
    result = {}
    for record in records:
        key = record[field]
        if not key or key in result:
            raise ValueError(f'Duplicate or empty {field}: {key}')
        result[key] = record
    return result


def definitions(root: pathlib.Path) -> dict[str, dict[str, str]]:
    result = {}
    # Discover new requirement documents rather than silently ignoring their IDs.
    sources = sorted(set(SOURCES) | {p.relative_to(root).as_posix() for p in (root / REQUIREMENTS).glob('*.md')})
    for path in sources:
        content = (root / path).read_text()
        matches = list(DEFINITION.finditer(content))
        for position, match in enumerate(matches):
            identifier = match[1]
            if identifier.startswith('AMBIGUITY-'):
                continue
            if identifier in result:
                raise ValueError(f'Duplicate definition: {identifier}')
            paragraph_end = content.find('\n\n', match.start())
            next_definition = matches[position + 1].start() if position + 1 < len(matches) else len(content)
            end = min(paragraph_end if paragraph_end >= 0 else len(content), next_definition)
            result[identifier] = {'source': path, 'text': content[match.start():end].strip()}
    return result


def retained(root: pathlib.Path) -> list[pathlib.Path]:
    paths = [p for p in root.glob('*.md') if p.is_file()]
    for directory in ('docs', '.agents/skills'):
        paths += [p for p in (root / directory).rglob('*') if p.is_file() and '__pycache__' not in p.parts]
    return sorted(set(paths))


def slug(heading: str) -> str:
    # GitHub heading IDs retain letters/numbers/hyphens, strip inline markup and punctuation.
    text = re.sub(r'\[([^]]+)\]\([^)]*\)', r'\1', heading).replace('`', '').lower()
    return re.sub(r'[^\w\- ]', '', text).replace(' ', '-')


def anchors(content: str) -> set[str]:
    result = set(re.findall(r'<a\s+(?:id|name)=["\']([^"\']+)', content))
    seen: dict[str, int] = {}
    for heading in re.findall(r'^#{1,6}\s+(.+?)(?:\s+#+)?$', content, re.MULTILINE):
        base = slug(heading)
        count = seen.get(base, 0)
        result.add(base if not count else f'{base}-{count}')
        seen[base] = count + 1
    return result


def check_links(root: pathlib.Path, paths: list[pathlib.Path]) -> None:
    for path in paths:
        if path.suffix != '.md':
            continue
        # Code fences are examples, not rendered navigation.
        content = re.sub(r'^```[^\n]*\n.*?^```\s*$', '', path.read_text(), flags=re.MULTILINE | re.DOTALL)
        for match in LINK.finditer(content):
            raw = match[1].strip('<>')
            parsed = urlsplit(raw)
            if parsed.scheme or parsed.netloc:
                continue
            target = (path.parent / unquote(parsed.path)).resolve() if parsed.path else path
            if not target.is_relative_to(root.resolve()) or not target.exists():
                raise ValueError(f'Broken local link in {path.relative_to(root)}: {raw}')
            if parsed.fragment and target.suffix == '.md' and unquote(parsed.fragment) not in anchors(target.read_text()):
                raise ValueError(f'Broken anchor in {path.relative_to(root)}: {raw}')


def check_scope(root: pathlib.Path, current: dict, retired: dict) -> dict:
    scope = keyed(rows(root, APPLICABILITY), 'requirement_identifier')
    if set(scope) != set(current) | set(retired):
        raise ValueError(f'Applicability population differs: missing={sorted((set(current) | set(retired)) - set(scope))}; extra={sorted(set(scope) - set(current) - set(retired))}')
    for sequence, (identifier, row) in enumerate(scope.items(), 1):
        if row['sequence'] != str(sequence):
            raise ValueError(f'Invalid scope sequence: {identifier}')
        state = row['disposition']
        reason = row['milestone_or_justification']
        if state not in {'Included', 'Future', 'Not Applicable'} or not reason or not row['responsible_owner']:
            raise ValueError(f'Invalid applicability: {identifier}')
        if (state == 'Included') != (reason == 'Development Baseline'):
            raise ValueError(f'Invalid milestone/justification: {identifier}')
        if identifier in retired and (state != 'Not Applicable' or retired[identifier]['replacement'] not in reason):
            raise ValueError(f'Retired process needs explicit replacement disposition: {identifier}')
    return scope


def check_examples(root: pathlib.Path, current: dict, retired: dict) -> list[dict]:
    examples = rows(root, EXAMPLES)
    keyed(examples, 'example_id')
    known = set(current) | set(retired)
    # Resolved ambiguity records were historical metadata, not product obligations.
    historical = keyed(rows(root, 'docs/research/verification-ambiguity-history.csv'), 'identifier')
    covered = set()
    for row in examples:
        selected = row['identifiers'].split(';')
        if len(selected) != len(set(selected)) or set(selected) - known - set(historical):
            raise ValueError(f'Invalid acceptance selector: {row["example_id"]}')
        if not all(row.get(key) for key in ('required_methods', 'acceptance_criteria', 'evidence_owner', 'final_approver')):
            raise ValueError(f'Incomplete acceptance assignment: {row["example_id"]}')
        allowed_methods = {'Inspection', 'Automated Test', 'Analysis', 'Representative Evaluation', 'Demonstration'}
        if set(row['required_methods'].split(', ')) - allowed_methods:
            raise ValueError(f'Unknown Required method: {row["example_id"]}')
        covered.update(selected)
    # The former plan assigned the functional and Autonomous Participant sets.
    # NFR/performance/profile sources continue to own their specialized catalogues.
    assigned_sources = {REQUIREMENTS + 'training-simulation-initial-requirements.md', REQUIREMENTS + 'training-simulation-autonomous-participant-requirements.md'}
    expected = {key for key, value in current.items() if value['source'] in assigned_sources}
    if expected - covered:
        raise ValueError(f'Acceptance criteria missing: {sorted(expected - covered)}')
    return examples


def check_traces(root: pathlib.Path, known: set[str]) -> tuple[dict, dict]:
    claims = keyed(rows(root, CLAIMS), 'architecture_claim_key')
    definition_text = (root / 'docs/architecture/0010-cross-cutting-architecture-and-verification.md').read_text()
    described = set(re.findall(r'^\| `(AC-[A-Z0-9-]+)`', definition_text, re.MULTILINE))
    if set(claims) != described:
        raise ValueError('Architecture Claim text/register populations differ')
    for key, row in claims.items():
        source = (root / row['governing_source']).resolve()
        if not source.is_relative_to(root.resolve()) or not source.is_file():
            raise ValueError(f'Missing claim source: {key}')
        for field, values in {
            'decision_state': {'Accepted', 'Deferred', 'Superseded'},
            'baseline_applicability': {'Included', 'Future', 'Not Applicable'},
            'realization_state': {'Not Implemented', 'Partial', 'Implemented'},
            'evidence_state': {'Not Run', 'Blocked', 'Fail', 'Pass'},
        }.items():
            if row[field] not in values:
                raise ValueError(f'Invalid claim state {field}: {key}')
        trace_ids = re.findall(ID, row['requirement_trace_relations'])
        if not trace_ids or set(trace_ids) - known:
            raise ValueError(f'Invalid claim requirement trace: {key}')
        if row['evidence_state'] == 'Pass' and row['realization_state'] != 'Implemented':
            raise ValueError(f'Pass without implemented claim: {key}')
    commitments = keyed(rows(root, COMMITMENTS), 'design_commitment_id')
    sdds = {re.search(r'^# (SDD-[0-9]{4}):', p.read_text())[1]: p for p in (root / 'docs/design').glob('[0-9]*.md')}
    described_dc = set()
    for path in sdds.values():
        described_dc.update(re.findall(r'^- `(DC-[A-Z0-9-]+)`:', path.read_text(), re.MULTILINE))
    if described_dc != set(commitments):
        raise ValueError('Design Commitment text/register populations differ')
    view_ids = anchors((root / 'docs/architecture/software-architecture-description.md').read_text())
    for key, row in commitments.items():
        if row['governing_sdd'] not in sdds:
            raise ValueError(f'Missing SDD: {key}')
        if set(row['requirement_traces'].split('|')) - known or not row['requirement_traces']:
            raise ValueError(f'Invalid design requirement trace: {key}')
        if set(row['architecture_claim_traces'].split('|')) - set(claims) or not row['architecture_claim_traces']:
            raise ValueError(f'Invalid design claim trace: {key}')
        if set(row['sad_view_traces'].split('|')) - view_ids:
            raise ValueError(f'Invalid design architecture-view trace: {key}')
        for field, values in {
            'decision_state': {'Proposed', 'Accepted', 'Superseded'},
            'applicability_state': {'Included', 'Future', 'Not Applicable'},
            'realization_state': {'Not Implemented', 'Partial', 'Implemented'},
            'evidence_state': {'Planned', 'Not Run', 'Blocked', 'Fail', 'Pass'},
        }.items():
            if row[field] not in values:
                raise ValueError(f'Invalid design state {field}: {key}')
        if row['evidence_state'] == 'Pass' and row['realization_state'] != 'Implemented':
            raise ValueError(f'Pass without implemented design: {key}')
        body = sdds[row['governing_sdd']].read_text()
        if row['verification_approach'] not in body or not row['responsible_owner']:
            raise ValueError(f'Missing design acceptance criterion/owner: {key}')
    return claims, commitments


def validate(root: pathlib.Path = ROOT, diagrams: bool = True) -> tuple:
    current = definitions(root)
    retired = keyed(rows(root, MIGRATION), 'retired_identifier')
    if set(current) & set(retired):
        raise ValueError('A retired process still has an active definition')
    for key, row in retired.items():
        if row['replacement'] not in current or not row['reason'] or not row['previous_statement']:
            raise ValueError(f'Incomplete migration disposition: {key}')
    scope = check_scope(root, current, retired)
    examples = check_examples(root, current, retired)
    claims, commitments = check_traces(root, set(current) | set(retired))
    check_links(root, retained(root))
    if diagrams:
        spec = importlib.util.spec_from_file_location('render_diagrams', root / 'scripts/render-diagrams.py')
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        module.check(root / 'docs/architecture/diagrams')
    return current, retired, scope, examples, claims, commitments


def write_csv(path: pathlib.Path, fields: list[str], records: list[dict]) -> None:
    with path.open('w', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=fields, lineterminator='\n')
        writer.writeheader()
        writer.writerows(records)


def role(path: str) -> str:
    if path.startswith('docs/research/'):
        return 'Reference'
    if pathlib.Path(path).suffix == '.svg' or path.endswith('render-manifest.json'):
        return 'Generated'
    if path.endswith('README.md') or path == 'AGENTS.md' or path.startswith(('docs/agents/', '.agents/')):
        return 'Routed'
    return 'Controlled'


def source_artifacts(root: pathlib.Path, inventory: list[dict]) -> list[dict]:
    result = []
    for row in inventory:
        if row['role'] != 'Controlled':
            continue
        path = row['path']
        classification = 'Architecture' if path.startswith(('docs/adr/', 'docs/architecture/')) else 'Design' if path.startswith('docs/design/') else 'Governance/requirements source'
        result.append({'identifier': path, 'class': classification, 'source': path, 'status': row['status']})
    paths = [p for p in root.iterdir() if p.is_file() and p.suffix in {'.json', '.txt', '.toml'}]
    for directory in ('scripts', 'tests', 'src', 'include', 'cmake', 'triplets', 'toolchains', '.github'):
        paths += [p for p in (root / directory).rglob('*') if p.is_file() and '__pycache__' not in p.parts and p.suffix in {'.py', '.sh', '.cpp', '.h', '.hpp', '.cmake', '.json', '.yml', '.yaml', '.toml', '.txt', '.in'}]
    for path in sorted(set(paths)):
        relative = path.relative_to(root).as_posix()
        classification = 'Verification/automation' if relative.startswith(('scripts/', 'tests/', '.github/')) else 'Implementation/build source'
        result.append({'identifier': relative, 'class': classification, 'source': relative, 'status': 'Source only — no implementation acceptance or evidence Pass inferred'})
    return result


def generate(root: pathlib.Path, validated: tuple) -> None:
    current, retired, scope, examples, claims, commitments = validated
    output = root / 'build/docs'
    output.mkdir(parents=True, exist_ok=True)
    inventory = []
    references = []
    identifiers = set(current) | set(retired) | set(claims) | set(commitments)
    for path in retained(root):
        relative = path.relative_to(root).as_posix()
        classification = role(relative)
        content = path.read_text() if path.suffix == '.md' else ''
        owner = re.search(r'^(?:Canonical information owner|Owner): (.+)', content, re.MULTILINE)
        status = re.search(r'^Status: (.+)', content, re.MULTILINE)
        inventory.append({'path': relative, 'format': path.suffix.lstrip('.'), 'role': classification,
                          'owner': owner[1] if owner else 'Project owner (documentation policy)',
                          'status': status[1] if status else ('Reference — non-canonical' if classification == 'Reference' else 'Navigation' if classification == 'Routed' else 'Generated' if classification == 'Generated' else 'Per-record or owning source'),
                          'sha256': hashlib.sha256(path.read_bytes()).hexdigest()})
        if path.suffix in {'.md', '.csv'} and not relative.startswith('docs/research/'):
            for identifier in sorted(set(re.findall(ID, path.read_text())) & identifiers):
                references.append({'source': relative, 'identifier': identifier})
    write_csv(output / 'documents.csv', list(inventory[0]), inventory)
    artifacts = source_artifacts(root, inventory)
    artifacts += [{'identifier': key, 'class': 'Requirement', 'source': value['source'], 'status': scope[key]['disposition']} for key, value in current.items()]
    artifacts += [{'identifier': key, 'class': 'Architecture Claim', 'source': row['governing_source'], 'status': ' / '.join(row[k] for k in ('decision_state', 'baseline_applicability', 'realization_state', 'evidence_state'))} for key, row in claims.items()]
    sdd_paths = {re.search(r'^# (SDD-[0-9]{4}):', p.read_text())[1]: p.relative_to(root).as_posix() for p in (root / 'docs/design').glob('[0-9]*.md')}
    artifacts += [{'identifier': key, 'class': 'Design Commitment', 'source': sdd_paths[row['governing_sdd']], 'status': ' / '.join(row[k] for k in ('decision_state', 'applicability_state', 'realization_state', 'evidence_state'))} for key, row in commitments.items()]
    write_csv(output / 'artifacts.csv', ['identifier', 'class', 'source', 'status'], artifacts)
    write_csv(output / 'references.csv', ['source', 'identifier'], references)
    print(f'Generated {len(inventory)} documents, {len(artifacts)} artifacts and {len(references)} direct references in build/docs/ (not semantic impact proof).')


def requirement(root: pathlib.Path, identifier: str) -> None:
    current = definitions(root)
    retired = keyed(rows(root, MIGRATION), 'retired_identifier')
    if identifier in retired:
        row = retired[identifier]
        print(f'{identifier}: retired by ADR-0014; use {row["replacement"]}.\n{row["reason"]}')
        identifier = row['replacement']
    if identifier not in current:
        raise ValueError(f'Unknown requirement: {identifier}')
    item = current[identifier]
    print(f'{item["source"]}\n\n{item["text"]}\n')
    scope = keyed(rows(root, APPLICABILITY), 'requirement_identifier')[identifier]
    print(f'Applicability: {scope["disposition"]} — {scope["milestone_or_justification"]}')
    for row in rows(root, EXAMPLES):
        if identifier in row['identifiers'].split(';'):
            print(f'\n{row["example_id"]}: Required: {row["required_methods"]}; Supporting: {row["supporting_methods"]}\n{row["acceptance_criteria"]}\nEvidence owner: {row["evidence_owner"]}; final approver: {row["final_approver"]}')
    print('\nAssignments describe required evidence, not execution status. No product Pass is inferred.\nDirect references:')
    for directory in ('docs/architecture', 'docs/design'):
        for path in sorted((root / directory).rglob('*.md')):
            if identifier in path.read_text():
                print(f'- {path.relative_to(root)}')


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['check', 'generate', 'requirement'])
    parser.add_argument('identifier', nargs='?')
    args = parser.parse_args()
    try:
        if args.command == 'requirement':
            if not args.identifier:
                parser.error('requirement needs a stable identifier')
            requirement(ROOT, args.identifier)
        else:
            result = validate()
            if args.command == 'generate':
                generate(ROOT, result)
            else:
                print(f'Documentation: OK ({len(result[0])} current definitions, {len(result[1])} retired process IDs, {len(result[4])} claims, {len(result[5])} design commitments). This is structural validation, not product acceptance.')
    except (OSError, ValueError, KeyError) as error:
        print(f'Documentation: {error}', file=sys.stderr)
        raise SystemExit(1) from error


if __name__ == '__main__':
    main()
