#!/usr/bin/env python3
"""Throwaway operational proof for CPP-ENGINEERING-BASELINE-001."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import pathlib
import platform
import re
import shutil
import subprocess
import sys
from dataclasses import asdict, dataclass
from typing import Iterable, Sequence


ROOT = pathlib.Path(__file__).resolve().parents[1]
CONFIG = ROOT / "config"
EVIDENCE = ROOT / "evidence"
COMMAND_EVIDENCE = EVIDENCE / "commands"
BASELINE = "CPP-ENGINEERING-BASELINE-001"


@dataclass(frozen=True)
class Result:
    """One evidence-backed gate result."""

    gate: str
    status: str
    detail: str
    evidence: str | None = None


class ProofFailure(RuntimeError):
    """A proof command failed or a mandatory identity was absent."""


def load_json(path: pathlib.Path) -> object:
    """Load one UTF-8 JSON document."""
    with path.open(encoding="utf-8") as stream:
        return json.load(stream)


def platform_name() -> str:
    """Return the native proof platform or an unsupported environment name."""
    if os.name == "nt":
        return "windows"
    os_release = pathlib.Path("/etc/os-release")
    if os_release.exists():
        content = os_release.read_text(encoding="utf-8")
        if re.search(r"^ID=debian$", content, re.MULTILINE):
            return "debian"
    return "unsupported"


def command_path(command: str) -> pathlib.Path | None:
    """Resolve a command without accepting a differently named compiler."""
    resolved = shutil.which(command)
    return pathlib.Path(resolved).resolve() if resolved else None


def version_output(command: str) -> str:
    """Return combined version output for an installed command."""
    completed = subprocess.run(
        [command, "--version"],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    return f"{completed.stdout}\n{completed.stderr}".strip()


def sha256(path: pathlib.Path) -> str:
    """Hash one file without loading it into memory."""
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def record_command(
    name: str,
    command: Sequence[str],
    environment: dict[str, str] | None = None,
) -> str:
    """Run a command and retain its exact output and disposition."""
    COMMAND_EVIDENCE.mkdir(parents=True, exist_ok=True)
    command_environment = os.environ.copy()
    if environment:
        command_environment.update(environment)
    completed = subprocess.run(
        list(command),
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        env=command_environment,
    )
    evidence_path = COMMAND_EVIDENCE / f"{name}.log"
    evidence_path.write_text(
        "command: "
        + subprocess.list2cmdline(list(command))
        + f"\nexit_code: {completed.returncode}\n\n"
        + completed.stdout
        + completed.stderr,
        encoding="utf-8",
    )
    if completed.returncode != 0:
        raise ProofFailure(
            f"{name} failed; reproduce with: "
            + subprocess.list2cmdline(list(command))
        )
    return f"{completed.stdout}\n{completed.stderr}"


def null_paths(value: object, prefix: str = "") -> list[str]:
    """Return stable dotted paths for unresolved inventory values."""
    if isinstance(value, dict):
        missing: list[str] = []
        for key in sorted(value):
            child = f"{prefix}.{key}" if prefix else key
            if value[key] is None:
                missing.append(child)
            else:
                missing.extend(null_paths(value[key], child))
        return missing
    if isinstance(value, list):
        missing = []
        for index, child_value in enumerate(value):
            child = f"{prefix}[{index}]"
            if child_value is None:
                missing.append(child)
            else:
                missing.extend(null_paths(child_value, child))
        return missing
    return []


def validate_static_configuration() -> list[Result]:
    """Validate repository-owned proof configuration without build tools."""
    results: list[Result] = []
    json_paths = sorted(CONFIG.glob("*.json"))
    try:
        loaded = {path.name: load_json(path) for path in json_paths}
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        return [Result("configuration", "Fail", str(error))]

    baselines = [
        value.get("baseline")
        for value in loaded.values()
        if isinstance(value, dict) and "baseline" in value
    ]
    status = "Pass" if all(item == BASELINE for item in baselines) else "Fail"
    results.append(Result("configuration-baseline", status, str(baselines)))

    presets = load_json(ROOT / "CMakePresets.json")
    assert isinstance(presets, dict)
    names = {
        item["name"]
        for item in presets["configurePresets"]
        if isinstance(item, dict) and not item.get("hidden", False)
    }
    required = {
        "dev-debian",
        "debug-debian",
        "release-debian",
        "asan-ubsan-debian",
        "tsan-debian",
        "coverage-debian",
        "fuzz-debian",
        "acceptance-debian",
        "reproducible-debian",
        "dev-windows",
        "debug-windows",
        "release-windows",
        "asan-windows",
        "acceptance-windows",
        "reproducible-windows",
    }
    missing_presets = sorted(required - names)
    results.append(
        Result(
            "canonical-presets",
            "Pass" if not missing_presets else "Fail",
            "all present" if not missing_presets else str(missing_presets),
        )
    )

    cmake_text = (ROOT / "CMakeLists.txt").read_text(encoding="utf-8")
    compiler_guard = all(
        token in cmake_text
        for token in ('STREQUAL "Clang"', '"MSVC cl.exe and GCC/G++')
    )
    results.append(
        Result(
            "clang-only-definition",
            "Pass" if compiler_guard else "Fail",
            "CMake rejects non-Clang compilers",
        )
    )

    tidy = (ROOT / ".clang-tidy").read_text(encoding="utf-8")
    checks_section = tidy.split("WarningsAsErrors:", maxsplit=1)[0]
    positive_wildcard = any(
        "*" in line and not line.lstrip().startswith("-*")
        for line in checks_section.splitlines()
    )
    results.append(
        Result(
            "clang-tidy-explicit-checks",
            "Fail" if positive_wildcard else "Pass",
            "no broad positive check wildcard",
        )
    )
    return results


def verify_inventory() -> list[Result]:
    """Verify exact native platform and tool identities."""
    inventory = load_json(CONFIG / "toolchains.json")
    assert isinstance(inventory, dict)
    current_platform = platform_name()
    results = [
        Result(
            "native-platform",
            "Pass" if current_platform in {"windows", "debian"} else "Blocked",
            f"detected {current_platform}: {platform.platform()}",
        )
    ]
    unresolved = null_paths(inventory)
    dependencies = load_json(CONFIG / "dependencies.json")
    unresolved.extend(
        f"dependencies.{path}" for path in null_paths(dependencies)
    )
    results.append(
        Result(
            "inventory-completeness",
            "Pass" if not unresolved else "Blocked",
            "complete" if not unresolved else ", ".join(unresolved),
            "config/toolchains.json",
        )
    )
    tools = inventory["tools"]
    assert isinstance(tools, dict)
    expected = {
        "cmake": ("cmake", str(tools["cmake"]["version"])),
        "ninja": ("ninja", str(tools["ninja"]["version"])),
        "sccache": ("sccache", str(tools["sccache"]["version"])),
        "clang-format": ("clang-format", str(tools["llvm"]["version"])),
        "clang-tidy": ("clang-tidy", str(tools["llvm"]["version"])),
        "clangd": ("clangd", str(tools["llvm"]["version"])),
        "llvm-cov": ("llvm-cov", str(tools["llvm"]["version"])),
        "llvm-profdata": (
            "llvm-profdata",
            str(tools["llvm"]["version"]),
        ),
        "llvm-symbolizer": (
            "llvm-symbolizer",
            str(tools["llvm"]["version"]),
        ),
    }
    compiler = "clang-cl" if current_platform == "windows" else "clang++"
    expected[compiler] = (compiler, str(tools["llvm"]["version"]))
    if current_platform == "debian":
        expected["llvm-ar"] = ("llvm-ar", str(tools["llvm"]["version"]))
        expected["llvm-ranlib"] = (
            "llvm-ranlib",
            str(tools["llvm"]["version"]),
        )
        expected["ld"] = ("ld", str(inventory["debian"]["binutils"]).split("-")[0])
        expected["objcopy"] = (
            "objcopy",
            str(inventory["debian"]["binutils"]).split("-")[0],
        )
        expected["strip"] = (
            "strip",
            str(inventory["debian"]["binutils"]).split("-")[0],
        )
    for gate, (command, expected_version) in expected.items():
        path = command_path(command)
        if path is None:
            results.append(Result(gate, "Blocked", f"{command} not found"))
            continue
        output = version_output(command)
        matches = expected_version in output
        evidence = f"{path} sha256={sha256(path)}; {output.splitlines()[0]}"
        results.append(
            Result(gate, "Pass" if matches else "Fail", evidence)
        )
    results.extend(verify_platform_components(current_platform, inventory))
    results.append(verify_vcpkg(tools))
    return results


def verify_platform_components(
    current_platform: str, inventory: dict[str, object]
) -> list[Result]:
    """Verify native SDK, OS, standard-library, and linker identities."""
    if current_platform == "windows":
        windows = inventory["windows"]
        assert isinstance(windows, dict)
        actual_sdk = os.environ.get("WindowsSDKVersion", "").rstrip("\\/")
        actual_tools = os.environ.get("VCToolsVersion", "")
        return [
            Result(
                "windows-sdk",
                "Pass" if actual_sdk == windows["sdk"] else "Blocked",
                f"expected {windows['sdk']}; detected {actual_sdk or 'unset'}",
            ),
            Result(
                "vctools-version",
                "Pass" if actual_tools == windows["vctools_version"] else "Blocked",
                "expected recorded VCToolsVersion; "
                f"detected {actual_tools or 'unset'}",
            ),
        ]
    if current_platform == "debian":
        debian = inventory["debian"]
        assert isinstance(debian, dict)
        checks: list[Result] = []
        release = pathlib.Path("/etc/os-release").read_text(encoding="utf-8")
        version_match = re.search(r'^VERSION_ID="?([^"\n]+)', release, re.MULTILINE)
        actual_os = version_match.group(1) if version_match else "unknown"
        checks.append(
            Result(
                "debian-version",
                "Pass" if actual_os == "13.6" else "Fail",
                f"expected 13.6; detected {actual_os}",
            )
        )
        package_expectations = {
            "libstdcxx": ("libstdc++6", str(debian["libstdcxx"])),
            "binutils": ("binutils", str(debian["binutils"])),
        }
        for gate, (package, expected_version) in package_expectations.items():
            completed = subprocess.run(
                ["dpkg-query", "-W", "-f=${Version}", package],
                check=False,
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
            )
            actual = completed.stdout.strip()
            checks.append(
                Result(
                    gate,
                    "Pass"
                    if completed.returncode == 0 and actual == expected_version
                    else "Fail",
                    f"expected {expected_version}; detected {actual or 'missing'}",
                )
            )
        return checks
    return [Result("platform-components", "Blocked", "not a native proof host")]


def verify_vcpkg(tools: dict[str, object]) -> Result:
    """Verify the vcpkg executable version and checked-out registry commit."""
    root_value = os.environ.get("VCPKG_ROOT")
    if not root_value:
        return Result("vcpkg", "Blocked", "VCPKG_ROOT is unset")
    root = pathlib.Path(root_value).resolve()
    executable = root / ("vcpkg.exe" if os.name == "nt" else "vcpkg")
    if not executable.is_file():
        return Result("vcpkg", "Blocked", f"missing {executable}")
    version = subprocess.run(
        [str(executable), "version"],
        check=False,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    commit = subprocess.run(
        ["git", "-C", str(root), "rev-parse", "HEAD"],
        check=False,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    expected_version = str(tools["vcpkg"]["version"])
    expected_commit = str(tools["vcpkg"]["registry_commit"])
    matches = (
        version.returncode == 0
        and expected_version in version.stdout
        and commit.returncode == 0
        and commit.stdout.strip() == expected_commit
    )
    return Result(
        "vcpkg",
        "Pass" if matches else "Fail",
        f"version={version.stdout.strip()}; commit={commit.stdout.strip()}",
    )


def source_files() -> list[str]:
    """Return the explicit first-party C++ file set for format/lint gates."""
    paths: list[pathlib.Path] = []
    for pattern in ("include/**/*.h", "src/**/*.cc", "tests/**/*.cc",
                    "probes/**/*.cc", "fuzz/**/*.cc"):
        paths.extend(ROOT.glob(pattern))
    return [str(path.relative_to(ROOT)) for path in sorted(paths)]


def translation_units(build_directory: pathlib.Path) -> list[str]:
    """Return first-party files represented in the compilation database."""
    database = load_json(build_directory / "compile_commands.json")
    assert isinstance(database, list)
    units = {
        str(pathlib.Path(entry["file"]).resolve())
        for entry in database
        if isinstance(entry, dict)
        and "file" in entry
        and ROOT in pathlib.Path(entry["file"]).resolve().parents
    }
    return sorted(units)


def assert_gate_results(results: Iterable[Result]) -> None:
    """Fail when a mandatory gate is not a pass."""
    failures = [result for result in results if result.status != "Pass"]
    if failures:
        raise ProofFailure(
            "; ".join(f"{item.gate}: {item.status}" for item in failures)
        )


def run_format() -> None:
    """Run the pinned formatter as a non-mutating check."""
    record_command(
        "format",
        ["clang-format", "--dry-run", "--Werror", *source_files()],
    )


def configure_build_test(preset: str) -> None:
    """Configure, build, and test one canonical preset."""
    record_command(f"configure-{preset}", ["cmake", "--preset", preset])
    record_command(f"build-{preset}", ["cmake", "--build", "--preset", preset])
    if not preset.startswith("fuzz-"):
        record_command(
            f"test-{preset}",
            ["ctest", "--preset", preset, "--no-tests=error"],
        )
    cache = ROOT / "build" / preset / "CMakeCache.txt"
    if cache.exists():
        content = cache.read_text(encoding="utf-8", errors="replace")
        match = re.search(r"CMAKE_CXX_COMPILER:FILEPATH=(.+)", content)
        if match and pathlib.Path(match.group(1)).name.lower() in {
            "cl.exe", "cl", "gcc", "gcc.exe", "g++", "g++.exe"
        }:
            raise ProofFailure(f"unauthorized compiler in {cache}")
        linker = re.search(r"CMAKE_LINKER:FILEPATH=(.+)", content)
        if platform_name() == "windows" and (
            linker is None
            or pathlib.Path(linker.group(1)).name.lower() not in {"link", "link.exe"}
        ):
            raise ProofFailure(f"native Windows link.exe not selected in {cache}")


def run_tidy(preset: str) -> None:
    """Run clang-tidy using the preset's compilation database."""
    build_directory = ROOT / "build" / preset
    record_command(
        f"tidy-{preset}",
        [
            "clang-tidy",
            "-p",
            str(build_directory),
            *translation_units(build_directory),
        ],
    )


def run_fuzz(seconds: int) -> None:
    """Run the minimal Debian fuzz target for a bounded duration."""
    preset = "fuzz-debian"
    configure_build_test(preset)
    executable = ROOT / "build" / preset / "proof_parser_fuzz"
    record_command(
        "fuzz",
        [str(executable), f"-max_total_time={seconds}", "-print_final_stats=1"],
    )


def run_pr() -> None:
    """Run the same pull-request gates locally and in CI."""
    results = [*validate_static_configuration(), *verify_inventory()]
    write_results(results)
    assert_gate_results(results)
    run_format()
    current = platform_name()
    if current == "debian":
        configure_build_test("dev-debian")
        run_tidy("dev-debian")
        configure_build_test("asan-ubsan-debian")
        run_fuzz(60)
    elif current == "windows":
        configure_build_test("dev-windows")
        run_tidy("dev-windows")
        configure_build_test("asan-windows")
    else:
        raise ProofFailure("PR gates require native Windows or Debian")


def run_nightly(fuzz_seconds: int = 900) -> None:
    """Run merge/nightly-class gates available to the native platform."""
    run_pr()
    current = platform_name()
    if current == "debian":
        configure_build_test("tsan-debian")
        run_coverage()
        run_fuzz(fuzz_seconds)


def run_coverage() -> None:
    """Generate and retain Clang source-based coverage evidence."""
    preset = "coverage-debian"
    record_command(f"configure-{preset}", ["cmake", "--preset", preset])
    record_command(f"build-{preset}", ["cmake", "--build", "--preset", preset])
    profile_dir = EVIDENCE / "coverage"
    profile_dir.mkdir(parents=True, exist_ok=True)
    record_command(
        f"test-{preset}",
        ["ctest", "--preset", preset, "--no-tests=error"],
        {"LLVM_PROFILE_FILE": str(profile_dir / "%p.profraw")},
    )
    raw_profiles = sorted(str(path) for path in profile_dir.glob("*.profraw"))
    if not raw_profiles:
        raise ProofFailure("coverage tests produced no raw profiles")
    merged = profile_dir / "proof.profdata"
    record_command(
        "coverage-merge",
        ["llvm-profdata", "merge", "-sparse", *raw_profiles, "-o", str(merged)],
    )
    test_binary = ROOT / "build" / preset / "sacramento_proof_tests"
    shared_library = ROOT / "build" / preset / "libsacramento_proof_core.so"
    record_command(
        "coverage-report",
        [
            "llvm-cov",
            "report",
            str(test_binary),
            f"-object={shared_library}",
            f"-instr-profile={merged}",
        ],
    )


def binary_paths(directory: pathlib.Path) -> list[pathlib.Path]:
    """Return proof deliverables whose bytes must reproduce."""
    names = (
        "sacramento_proof_app.exe",
        "sacramento_proof_core.dll",
        "sacramento_proof_app",
        "libsacramento_proof_core.so",
    )
    return sorted(path for path in directory.rglob("*") if path.name in names)


def release_artifact_paths(directory: pathlib.Path) -> list[pathlib.Path]:
    """Return product binaries and their retained full debug information."""
    binaries = binary_paths(directory)
    symbols = sorted(
        path
        for path in directory.rglob("*")
        if path.is_file() and (path.suffix == ".pdb" or path.name.endswith(".debug"))
    )
    return [*binaries, *symbols]


def run_reproducibility(preset: str) -> None:
    """Build twice without caches and compare product artifact hashes."""
    directories = [ROOT / "build" / "repro-a", ROOT / "build" / "repro-b"]
    environment = {
        "SCCACHE_DISABLE": "1",
        "VCPKG_BINARY_SOURCES": "clear",
        "SOURCE_DATE_EPOCH": "0",
    }
    for index, directory in enumerate(directories, start=1):
        if directory.exists():
            shutil.rmtree(directory)
        record_command(
            f"repro-configure-{index}",
            [
                "cmake",
                "--preset",
                preset,
                "-B",
                str(directory),
                "-DCMAKE_CXX_COMPILER_LAUNCHER=",
            ],
            environment,
        )
        record_command(
            f"repro-build-{index}",
            ["cmake", "--build", str(directory)],
            environment,
        )
    hashes = [
        {
            str(path.relative_to(directory)): sha256(path)
            for path in release_artifact_paths(directory)
        }
        for directory in directories
    ]
    artifact_dir = EVIDENCE / "artifacts"
    artifact_dir.mkdir(parents=True, exist_ok=True)
    (artifact_dir / "reproducibility.json").write_text(
        json.dumps(hashes, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    if not hashes[0] or hashes[0] != hashes[1]:
        raise ProofFailure("same-platform clean builds are not bit-for-bit equal")


def run_hardening_inspection(preset: str) -> None:
    """Retain native binary hardening evidence."""
    directory = ROOT / "build" / preset
    binaries = binary_paths(directory)
    if not binaries:
        raise ProofFailure(f"no product binaries found below {directory}")
    if platform_name() == "windows":
        for index, binary in enumerate(binaries):
            output = record_command(
                f"hardening-windows-{index}",
                ["llvm-readobj", "--file-headers", "--coff-load-config", str(binary)],
            )
            required = ("DYNAMIC_BASE", "NX_COMPAT", "HIGH_ENTROPY_VA", "GUARD_CF")
            missing = [marker for marker in required if marker not in output]
            if missing:
                raise ProofFailure(
                    f"{binary.name} lacks Windows hardening: {missing}"
                )
    else:
        for index, binary in enumerate(binaries):
            output = record_command(
                f"hardening-debian-{index}",
                ["readelf", "--wide", "--program-headers", "--dynamic", str(binary)],
            )
            if "GNU_RELRO" not in output or "BIND_NOW" not in output:
                raise ProofFailure(f"{binary.name} lacks RELRO or immediate binding")
            stack_lines = [line for line in output.splitlines() if "GNU_STACK" in line]
            if not stack_lines or any(
                re.search(r"\bRWE\b", line) for line in stack_lines
            ):
                raise ProofFailure(f"{binary.name} has an executable or unknown stack")


def run_release() -> None:
    """Run release build, binary inspection, and clean reproducibility proof."""
    results = [*validate_static_configuration(), *verify_inventory()]
    write_results(results)
    assert_gate_results(results)
    run_format()
    current = platform_name()
    if current not in {"windows", "debian"}:
        raise ProofFailure("release proof requires native Windows or Debian")
    preset = f"release-{current}"
    configure_build_test(preset)
    run_hardening_inspection(preset)
    run_reproducibility(f"reproducible-{current}")


def write_results(results: Sequence[Result]) -> None:
    """Persist platform evidence in JSON and Markdown."""
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    current = platform_name()
    payload = {
        "baseline": BASELINE,
        "platform": current,
        "results": [asdict(result) for result in results],
    }
    (EVIDENCE / f"{current}.json").write_text(
        json.dumps(payload, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    lines = [
        "# C++ Toolchain Proof Result",
        "",
        f"Baseline: `{BASELINE}`",
        "",
        f"Platform: `{current}`",
        "",
        "| Gate | Status | Detail | Evidence |",
        "| --- | --- | --- | --- |",
    ]
    for result in results:
        detail = result.detail.replace("|", "\\|").replace("\n", " ")
        evidence = result.evidence or "—"
        lines.append(
            f"| `{result.gate}` | {result.status} | {detail} | {evidence} |"
        )
    (EVIDENCE / f"{current}.md").write_text(
        "\n".join(lines) + "\n", encoding="utf-8"
    )


def describe_install() -> int:
    """Describe installation without changing the host."""
    inventory = load_json(CONFIG / "toolchains.json")
    missing = null_paths(inventory)
    print("Install mode would obtain and hash-verify the pinned inputs.")
    if missing:
        print("Installation is blocked by unresolved source identities:")
        for path in missing:
            print(f"- {path}")
        return 2
    print("No installer is implemented in this throwaway proof.")
    return 2


def parse_args() -> argparse.Namespace:
    """Parse the intentionally small prototype command interface."""
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "command",
        choices=(
            "static",
            "verify",
            "install",
            "pre-push",
            "pr",
            "nightly",
            "weekly",
            "release",
        ),
    )
    return parser.parse_args()


def main() -> int:
    """Execute one proof phase and preserve its disposition."""
    args = parse_args()
    if args.command == "install":
        return describe_install()
    if args.command == "static":
        results = validate_static_configuration()
    elif args.command == "verify":
        results = [*validate_static_configuration(), *verify_inventory()]
    elif args.command in {"pre-push", "pr", "nightly", "weekly", "release"}:
        try:
            if args.command in {"pre-push", "pr"}:
                run_pr()
            elif args.command == "nightly":
                run_nightly()
            elif args.command == "weekly":
                run_nightly(3600)
            else:
                run_release()
            return 0
        except ProofFailure as error:
            print(f"proof failed: {error}", file=sys.stderr)
            return 1
    else:
        raise AssertionError(f"unhandled command: {args.command}")
    write_results(results)
    for result in results:
        print(f"{result.status:7} {result.gate}: {result.detail}")
    return 0 if all(item.status == "Pass" for item in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
