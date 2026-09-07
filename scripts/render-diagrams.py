#!/usr/bin/env python3
"""Render local PlantUML/C4 sources with pinned tools; never send source online."""
from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import shutil
import subprocess
import tarfile
import tempfile
import urllib.request

# Trace: DOC-MAINTENANCE-001. Rendering is not product verification evidence.

ROOT = pathlib.Path(__file__).resolve().parents[1]
DIRECTORY = ROOT / 'docs/architecture/diagrams'
JAR_NAME = 'plantuml-mit-1.2026.8.jar'
JAR_HASH = '3629c9cd017c7f73e6450396eea0040216c7e1eef8473ce33cc1aad469dab2f9'
JAR_URL = f'https://github.com/plantuml/plantuml/releases/download/v1.2026.8/{JAR_NAME}'
JRE_NAME = 'OpenJDK21U-jre_x64_linux_hotspot_21.0.12.1_1.tar.gz'
JRE_HASH = '2413149700df0f7d440500a84a8f764c535f21e5a5e87d38328b64eec2c5b500'
JRE_URL = f'https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.12.1%2B1/{JRE_NAME}'


def digest(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def download(url: str, target: pathlib.Path, expected: str) -> None:
    if not target.exists():
        with tempfile.NamedTemporaryFile(dir=target.parent) as temporary:
            with urllib.request.urlopen(url, timeout=60) as response:
                shutil.copyfileobj(response, temporary)
            temporary.flush()
            if digest(pathlib.Path(temporary.name)) != expected:
                raise ValueError(f'Download digest mismatch: {url}')
            shutil.copyfile(temporary.name, target)
    if digest(target) != expected:
        raise ValueError(f'Cached tool digest mismatch: {target}')


def provenance(directory: pathlib.Path = DIRECTORY) -> dict:
    paths = sorted(directory.glob('*.puml')) + sorted(directory.glob('*.svg'))
    return {
        'renderer': JAR_NAME,
        'renderer_sha256': JAR_HASH,
        'java_distribution': JRE_NAME,
        'java_archive_sha256': JRE_HASH,
        'render_script_sha256': digest(pathlib.Path(__file__)),
        'files': {path.name: digest(path) for path in paths},
    }


def check(directory: pathlib.Path = DIRECTORY) -> None:
    sources = {p.stem for p in directory.glob('*.puml')}
    outputs = {p.stem for p in directory.glob('*.svg')}
    if not sources or sources != outputs:
        raise ValueError('Diagram source/preview population differs')
    recorded = json.loads((directory / 'render-manifest.json').read_text())
    if recorded != provenance(directory):
        raise ValueError('Stale diagram provenance; run python3 scripts/render-diagrams.py')
    for output in directory.glob('*.svg'):
        text = output.read_text()
        if '<svg' not in text or 'Syntax Error' in text:
            raise ValueError(f'Invalid diagram preview: {output.name}')


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Offline source/preview provenance check; does not rerender')
    parser.add_argument('--tools-dir', type=pathlib.Path, default=ROOT / '.cache/documentation', help='Verified download cache (Linux x86_64 JRE)')
    args = parser.parse_args()
    if args.check:
        check()
        print('Diagram provenance: OK')
        return
    cache = args.tools_dir.resolve()
    cache.mkdir(parents=True, exist_ok=True)
    jar = cache / JAR_NAME
    archive = cache / JRE_NAME
    download(JAR_URL, jar, JAR_HASH)
    download(JRE_URL, archive, JRE_HASH)
    # Always extract the verified archive into a fresh private directory; no
    # mutable installed JRE or host Graphviz can silently become the renderer.
    with tempfile.TemporaryDirectory(prefix='sacramento-diagrams-') as temporary:
        scratch = pathlib.Path(temporary)
        with tarfile.open(archive) as bundle:
            bundle.extractall(scratch, filter='data')
        java = scratch / 'jdk-21.0.12.1+1-jre/bin/java'
        sources = sorted(DIRECTORY.glob('*.puml'))
        if not sources:
            raise ValueError('No diagram sources')
        for source in sources:
            content = source.read_text()
            if '!includeurl' in content or 'https://' in content or 'http://' in content:
                raise ValueError(f'Remote diagram inclusion prohibited: {source.name}')
            shutil.copyfile(source, scratch / source.name)
        subprocess.run([str(java), '-Djava.awt.headless=true', '-Dfile.encoding=UTF-8',
                        '-jar', str(jar), '-charset', 'UTF-8', '-tsvg', '-nometadata',
                        '-failfast2', *[str(scratch / s.name) for s in sources]], check=True)
        for source in sources:
            generated = scratch / source.with_suffix('.svg').name
            if not generated.is_file() or 'Syntax Error' in generated.read_text():
                raise ValueError(f'Render failed: {source.name}')
        for source in sources:
            shutil.copyfile(scratch / source.with_suffix('.svg').name, source.with_suffix('.svg'))
    (DIRECTORY / 'render-manifest.json').write_text(json.dumps(provenance(), indent=2) + '\n')
    check()
    print(f'Rendered {len(sources)} diagrams. Review SVG changes before acceptance.')


if __name__ == '__main__':
    main()
