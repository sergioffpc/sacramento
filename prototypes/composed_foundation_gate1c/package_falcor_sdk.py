#!/usr/bin/env python3
"""Assemble a deterministic, hash-addressed Falcor SDK prototype."""

import argparse
import hashlib
import json
import os
import shutil
import stat
import zipfile
from pathlib import Path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def copy_file(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)


def copy_tree_files(source: Path, destination: Path, suffixes=None) -> None:
    for path in sorted(source.rglob("*")):
        if not path.is_file():
            continue
        if suffixes is not None and path.suffix.lower() not in suffixes:
            continue
        copy_file(path, destination / path.relative_to(source))


def resolved_package(link: Path, cache: Path) -> Path:
    target = os.readlink(link)
    marker = "/chk/"
    if marker not in target:
        raise SystemExit(f"unexpected Packman link: {link} -> {target}")
    return cache / "chk" / target.split(marker, 1)[1]


def add_license(package: str, root: Path, destination: Path) -> None:
    candidates = sorted(
        path
        for path in root.rglob("*")
        if path.is_file()
        and ("license" in path.name.lower() or "copyright" in path.name.lower())
    )
    for index, path in enumerate(candidates):
        copy_file(path, destination / package / f"{index:03d}-{path.name}")


def inventory_tree(root: Path) -> list[dict]:
    result = []
    for path in sorted(root.rglob("*")):
        if path.is_file():
            result.append(
                {
                    "path": path.relative_to(root).as_posix(),
                    "sha256": sha256(path),
                    "size": path.stat().st_size,
                }
            )
    return result


def write_zip(source: Path, archive: Path) -> None:
    archive.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED) as output:
        for path in sorted(source.rglob("*")):
            if not path.is_file():
                continue
            info = zipfile.ZipInfo(path.relative_to(source).as_posix())
            info.date_time = (1980, 1, 1, 0, 0, 0)
            info.external_attr = (stat.S_IFREG | 0o644) << 16
            output.writestr(info, path.read_bytes(), compress_type=zipfile.ZIP_DEFLATED)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--build", type=Path, required=True)
    parser.add_argument("--packman-cache", type=Path, required=True)
    parser.add_argument("--aftermath", type=Path, required=True)
    parser.add_argument("--redist", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--archive", type=Path, required=True)
    args = parser.parse_args()

    output = args.output
    if output.exists():
        raise SystemExit(f"refusing to overwrite SDK directory: {output}")
    output.mkdir(parents=True)

    packages = {
        name: resolved_package(args.source / "external/packman" / name, args.packman_cache)
        for name in ("deps", "nanovdb", "nvtt", "python", "rtxdi", "slang")
    }

    header_suffixes = {".h", ".hpp", ".hxx", ".inl", ".slang", ".slangh"}
    copy_tree_files(args.source / "Source/Falcor", output / "include/Falcor", header_suffixes)
    copy_file(args.build / "git_version/git_version.h", output / "include/git_version.h")
    copy_tree_files(args.source / "external/include", output / "include", header_suffixes)
    copy_tree_files(args.source / "external/fmt/include", output / "include", header_suffixes)
    copy_tree_files(args.source / "external/pybind11/include", output / "include", header_suffixes)
    copy_tree_files(args.source / "external/vulkan-headers/include", output / "include", header_suffixes)
    copy_tree_files(args.source / "external/imgui", output / "include", {".h"})
    for name in ("deps", "nanovdb", "nvtt", "rtxdi", "slang"):
        include = packages[name] / "include"
        if include.is_dir():
            copy_tree_files(include, output / "include", header_suffixes)

    copy_file(args.build / "Source/Falcor/Falcor.lib", output / "lib/Falcor.lib")
    copy_file(args.build / "bin/Falcor.dll", output / "bin/Falcor.dll")

    runtime_roots = [
        packages["deps"] / "bin",
        packages["slang"] / "bin",
        packages["nvtt"],
        args.aftermath / "lib/x64",
        args.redist,
    ]
    for root in runtime_roots:
        for dll in sorted(root.glob("*.dll")):
            copy_file(dll, output / "bin" / dll.name)

    python = packages["python"]
    copy_tree_files(python, output / "python")
    for dll in sorted(python.glob("python*.dll")):
        copy_file(dll, output / "bin" / dll.name)

    add_license("falcor", args.source, output / "licenses")
    for name, root in packages.items():
        add_license(name, root, output / "licenses")
    add_license("aftermath", args.aftermath, output / "licenses")

    packman_inputs = {}
    for link in sorted((args.source / "external/packman").iterdir()):
        if not link.is_symlink() or "/chk/" not in os.readlink(link):
            continue
        package = resolved_package(link, args.packman_cache)
        packman_inputs[link.name] = {
            "identity": package.relative_to(args.packman_cache).as_posix(),
            "files": inventory_tree(package),
        }
    vendor_inputs = {
        "format": "sacramento.falcor-vendor-inputs.v1",
        "dependencies_xml_sha256": sha256(args.source / "dependencies.xml"),
        "packman": packman_inputs,
        "aftermath": inventory_tree(args.aftermath),
    }
    (output / "vendor-inputs.json").write_text(
        json.dumps(vendor_inputs, indent=2) + "\n", encoding="utf-8"
    )

    files = []
    for path in sorted(output.rglob("*")):
        if path.is_file():
            files.append(
                {
                    "path": path.relative_to(output).as_posix(),
                    "sha256": sha256(path),
                    "size": path.stat().st_size,
                }
            )
    manifest = {
        "format": "sacramento.falcor-sdk-manifest.v1",
        "falcor_commit": "9dc819c162b2070335c65060436041690b7937f8",
        "features": {
            "aftermath": True,
            "cuda": False,
            "d3d12": False,
            "nvapi": False,
            "optix": False,
            "python_internal": True,
            "slang": True,
            "vulkan": True,
        },
        "files": files,
    }
    manifest_path = output / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    write_zip(output, args.archive)
    print(
        json.dumps(
            {
                "archive": str(args.archive),
                "archive_sha256": sha256(args.archive),
                "file_count": len(files) + 1,
                "size": args.archive.stat().st_size,
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
