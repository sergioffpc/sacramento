"""Positive and negative checks for the documentation workflow, not product tests."""
import contextlib
import csv
import importlib.util
import io
import pathlib
import shutil
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('documentation', ROOT / 'scripts/documentation.py')
doc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(doc)


class DocumentationTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='sacramento-doc-test-')
        self.addCleanup(self.temporary.cleanup)
        self.root = pathlib.Path(self.temporary.name) / 'repo'
        shutil.copytree(ROOT, self.root, ignore=shutil.ignore_patterns('.git', '.cache', 'build', '__pycache__'))

    def change_row(self, path, change):
        records = doc.rows(self.root, path)
        change(records)
        doc.write_csv(self.root / path, list(records[0]), records)

    def rejects(self, message):
        return self.assertRaisesRegex(ValueError, message)

    def test_current_repository_is_structurally_valid(self):
        current, retired, _, examples, claims, commitments = doc.validate(self.root)
        self.assertIn('REQ-STATE-CONSISTENCY-001', current)
        self.assertIn('PROCESS-EVIDENCE-DEPENDENCY-006', retired)
        self.assertTrue(any('REQ-STATE-CONSISTENCY-001' in r['identifiers'].split(';') for r in examples))
        self.assertEqual(claims['AC-RUNTIME-004']['realization_state'], 'Not Implemented')
        self.assertEqual(commitments['DC-COOKER-023']['decision_state'], 'Proposed')

    def test_duplicate_definition_fails(self):
        with (self.root / doc.SOURCES[0]).open('a') as stream:
            stream.write('\n**REQ-STATE-CONSISTENCY-001** — duplicate\n')
        with self.rejects('Duplicate definition'):
            doc.validate(self.root)

    def test_new_requirement_source_cannot_escape_scope_reconciliation(self):
        (self.root / 'docs/requirements/new-capability.md').write_text('# New capability\n\n**REQ-NEW-CAPABILITY-001** — An explicit new obligation.\n')
        with self.rejects('Applicability population differs'):
            doc.validate(self.root)

    def test_adjacent_definitions_remain_separate_in_queries(self):
        (self.root / 'docs/requirements/new-capability.md').write_text('**REQ-FIRST-001** — first\n**REQ-SECOND-001** — second\n')
        definitions = doc.definitions(self.root)
        self.assertEqual(definitions['REQ-FIRST-001']['text'], '**REQ-FIRST-001** — first')
        self.assertEqual(definitions['REQ-SECOND-001']['text'], '**REQ-SECOND-001** — second')

    def test_missing_scope_row_fails(self):
        self.change_row(doc.APPLICABILITY, lambda records: records.pop())
        with self.rejects('Applicability population differs'):
            doc.validate(self.root)

    def test_unknown_scope_row_fails(self):
        self.change_row(doc.APPLICABILITY, lambda records: records[0].update(requirement_identifier='REQ-UNKNOWN-999'))
        with self.rejects('Applicability population differs'):
            doc.validate(self.root)

    def test_duplicate_scope_row_fails(self):
        self.change_row(doc.APPLICABILITY, lambda records: records.append(records[0]))
        with self.rejects('Duplicate'):
            doc.validate(self.root)

    def test_future_without_milestone_fails(self):
        self.change_row(doc.APPLICABILITY, lambda records: records[0].update(disposition='Future', milestone_or_justification=''))
        with self.rejects('Invalid applicability'):
            doc.validate(self.root)

    def test_retired_process_cannot_remain_included(self):
        def change(records):
            next(row for row in records if row['requirement_identifier'] == 'PROCESS-EVIDENCE-DEPENDENCY-006').update(disposition='Included', milestone_or_justification='Development Baseline')
        self.change_row(doc.APPLICABILITY, change)
        with self.rejects('Retired process'):
            doc.validate(self.root)

    def test_migration_cannot_point_to_unknown_rule(self):
        self.change_row(doc.MIGRATION, lambda records: records[0].update(replacement='VERIFY-MISSING-999'))
        with self.rejects('Incomplete migration'):
            doc.validate(self.root)

    def test_unknown_acceptance_selector_fails(self):
        self.change_row(doc.EXAMPLES, lambda records: records[0].update(identifiers='REQ-UNKNOWN-999'))
        with self.rejects('Invalid acceptance selector'):
            doc.validate(self.root)

    def test_duplicate_acceptance_selector_fails(self):
        self.change_row(doc.EXAMPLES, lambda records: records[0].update(identifiers='GOAL-TRAINING-001;GOAL-TRAINING-001'))
        with self.rejects('Invalid acceptance selector'):
            doc.validate(self.root)

    def test_empty_acceptance_criterion_fails(self):
        self.change_row(doc.EXAMPLES, lambda records: records[0].update(acceptance_criteria=''))
        with self.rejects('Incomplete acceptance assignment'):
            doc.validate(self.root)

    def test_unknown_required_method_fails(self):
        self.change_row(doc.EXAMPLES, lambda records: records[0].update(required_methods='Looks fine'))
        with self.rejects('Unknown Required method'):
            doc.validate(self.root)

    def test_uncovered_functional_requirement_fails(self):
        def change(records):
            for row in records:
                row['identifiers'] = ';'.join(i for i in row['identifiers'].split(';') if i != 'REQ-STATE-CONSISTENCY-001')
        self.change_row(doc.EXAMPLES, change)
        with self.rejects('Acceptance criteria missing'):
            doc.validate(self.root)

    def test_missing_claim_source_fails(self):
        self.change_row(doc.CLAIMS, lambda records: records[0].update(governing_source='docs/missing.md'))
        with self.rejects('Missing claim source'):
            doc.validate(self.root)

    def test_unknown_claim_trace_fails(self):
        self.change_row(doc.CLAIMS, lambda records: records[0].update(requirement_trace_relations='Satisfies:REQ-UNKNOWN-999'))
        with self.rejects('Invalid claim requirement trace'):
            doc.validate(self.root)

    def test_claim_pass_cannot_be_inferred_from_accepted_decision(self):
        self.change_row(doc.CLAIMS, lambda records: records[0].update(evidence_state='Pass'))
        with self.rejects('Pass without implemented claim'):
            doc.validate(self.root)

    def test_claim_state_vocabulary_is_closed(self):
        self.change_row(doc.CLAIMS, lambda records: records[0].update(decision_state='Probably accepted'))
        with self.rejects('Invalid claim state'):
            doc.validate(self.root)

    def test_unknown_design_view_fails(self):
        self.change_row(doc.COMMITMENTS, lambda records: records[0].update(sad_view_traces='missing-view'))
        with self.rejects('Invalid design architecture-view trace'):
            doc.validate(self.root)

    def test_missing_design_criterion_fails(self):
        self.change_row(doc.COMMITMENTS, lambda records: records[0].update(verification_approach='DAC-MISSING-999'))
        with self.rejects('Missing design acceptance'):
            doc.validate(self.root)

    def test_broken_link_fails(self):
        with (self.root / 'README.md').open('a') as stream:
            stream.write('\n[missing](docs/not-here.md)\n')
        with self.rejects('Broken local link'):
            doc.validate(self.root)

    def test_broken_anchor_fails(self):
        with (self.root / 'README.md').open('a') as stream:
            stream.write('\n[missing](README.md#not-here)\n')
        with self.rejects('Broken anchor'):
            doc.validate(self.root)

    def test_fenced_examples_are_not_navigation(self):
        with (self.root / 'README.md').open('a') as stream:
            stream.write('\n```md\n[example](nonexistent-example.md)\n```\n')
        doc.validate(self.root)

    def test_duplicate_headings_use_github_suffix(self):
        self.assertEqual(doc.anchors('# Hello\n## Hello\n## Hello\n'), {'hello', 'hello-1', 'hello-2'})

    def test_new_document_format_is_not_silently_omitted(self):
        picture = self.root / 'docs/research/reference-picture.png'
        picture.write_bytes(b'fixture image bytes')
        self.assertIn(picture, doc.retained(self.root))
        with contextlib.redirect_stdout(io.StringIO()):
            doc.generate(self.root, doc.validate(self.root))
        self.assertIn('docs/research/reference-picture.png', (self.root / 'build/docs/documents.csv').read_text())

    def test_edited_diagram_source_requires_new_preview(self):
        with (self.root / 'docs/architecture/diagrams/context.puml').open('a') as stream:
            stream.write("' source edit\n")
        with self.rejects('Stale diagram provenance'):
            doc.validate(self.root)

    def test_edited_preview_requires_new_provenance(self):
        with (self.root / 'docs/architecture/diagrams/context.svg').open('a') as stream:
            stream.write('<!-- unexpected mutation -->\n')
        with self.rejects('Stale diagram provenance'):
            doc.validate(self.root)

    def test_generated_indexes_are_deterministic(self):
        with contextlib.redirect_stdout(io.StringIO()):
            doc.generate(self.root, doc.validate(self.root))
            before = {p.name: p.read_bytes() for p in (self.root / 'build/docs').glob('*.csv')}
            doc.generate(self.root, doc.validate(self.root))
        self.assertEqual(before, {p.name: p.read_bytes() for p in (self.root / 'build/docs').glob('*.csv')})
        with (self.root / 'build/docs/artifacts.csv').open() as stream:
            artifacts = {row['identifier']: row for row in csv.DictReader(stream)}
        claim = artifacts['AC-RUNTIME-004']
        self.assertIn('Not Implemented / Blocked', claim['status'])
        self.assertEqual(artifacts['scripts/documentation.py']['class'], 'Verification/automation')
        self.assertIn('no implementation acceptance', artifacts['scripts/documentation.py']['status'])

    def test_requirement_query_accumulates_rows_without_claiming_pass(self):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            doc.requirement(self.root, 'REQ-STATE-CONSISTENCY-001')
        text = output.getvalue()
        self.assertIn('Required:', text)
        self.assertIn('No product Pass is inferred', text)
        self.assertIn('Applicability: Included', text)

    def test_retired_requirement_query_routes_to_replacement(self):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            doc.requirement(self.root, 'PROCESS-EVIDENCE-DEPENDENCY-006')
        self.assertIn('use VERIFY-CHANGE-001', output.getvalue())


if __name__ == '__main__':
    unittest.main()
