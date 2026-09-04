#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mode="all"
compile_commands_dir="${repo_root}/build/dev-debian"
declare -a requested_paths=()

usage() {
  echo "usage: $0 [--format-only|--tidy-only] [--compile-commands DIR] [--] [PATH ...]" >&2
}

while (($#)); do
  case "$1" in
    --format-only)
      mode="format"
      shift
      ;;
    --tidy-only)
      mode="tidy"
      shift
      ;;
    --compile-commands)
      if (($# < 2)); then
        usage
        exit 2
      fi
      compile_commands_dir="$2"
      shift 2
      ;;
    --)
      shift
      requested_paths+=("$@")
      break
      ;;
    -*)
      usage
      exit 2
      ;;
    *)
      requested_paths+=("$1")
      shift
      ;;
  esac
done

is_cpp_path() {
  case "$1" in
    *.cc|*.cpp|*.cxx|*.c++|*.h|*.hh|*.hpp|*.hxx|*.inc) return 0 ;;
    *) return 1 ;;
  esac
}

is_translation_unit() {
  case "$1" in
    *.cc|*.cpp|*.cxx|*.c++) return 0 ;;
    *) return 1 ;;
  esac
}

declare -a files=()
if ((${#requested_paths[@]})); then
  for requested_path in "${requested_paths[@]}"; do
    if [[ "${requested_path}" = /* ]]; then
      candidate="${requested_path}"
    else
      candidate="${repo_root}/${requested_path}"
    fi
    if [[ ! -f "${candidate}" ]]; then
      echo "C++ style gate: missing file: ${requested_path}" >&2
      exit 2
    fi
    resolved="$(realpath "${candidate}")"
    if [[ "${resolved}" != "${repo_root}/"* ]]; then
      echo "C++ style gate: path escapes repository: ${requested_path}" >&2
      exit 2
    fi
    relative="${resolved#"${repo_root}/"}"
    if ! is_cpp_path "${relative}"; then
      echo "C++ style gate: unsupported file type: ${relative}" >&2
      exit 2
    fi
    files+=("${relative}")
  done
else
  while IFS= read -r -d '' path; do
    files+=("${path}")
  done < <(
    git -C "${repo_root}" ls-files --cached --others --exclude-standard -z -- \
      '*.cc' '*.cpp' '*.cxx' '*.c++' '*.h' '*.hh' '*.hpp' '*.hxx' '*.inc'
  )
fi

check_tool() {
  local tool="$1"
  local version
  if ! command -v "${tool}" >/dev/null; then
    echo "C++ style gate: missing pinned tool: ${tool}" >&2
    exit 2
  fi
  version="$(${tool} --version | head -n 1)"
  if [[ ! "${version}" =~ (^|[^0-9])22\.1\.2([^0-9]|$) ]]; then
    echo "C++ style gate: ${tool} must be version 22.1.2; found: ${version}" >&2
    exit 2
  fi
}

validate_exception_state() {
  python3 - "${repo_root}/config/cpp/exceptions.json" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
try:
    value = json.loads(path.read_text(encoding="utf-8"))
except (OSError, UnicodeError, json.JSONDecodeError) as error:
    raise SystemExit(f"C++ style gate: invalid exception register: {error}")

if value.get("schema_version") != 1:
    raise SystemExit("C++ style gate: unsupported exception-register schema")
if value.get("baseline") not in {
    "CPP-ENGINEERING-BASELINE-003",
    "CPP-ENGINEERING-BASELINE-004",
}:
    raise SystemExit("C++ style gate: exception register has an unknown baseline")
exceptions = value.get("exceptions")
if not isinstance(exceptions, list):
    raise SystemExit("C++ style gate: exceptions must be a list")
if exceptions:
    raise SystemExit(
        "C++ style gate: approved-exception matching is not implemented; "
        "refusing to waive diagnostics"
    )
PY

  if ((${#files[@]})) && (
    cd "${repo_root}"
    grep -nHE \
      'NOLINT|clang-format[[:space:]]+off|#[[:space:]]*pragma[[:space:]]+clang[[:space:]]+diagnostic[[:space:]]+ignored' \
      -- "${files[@]}"
  ); then
    echo "C++ style gate: inline suppression has no matched approved exception" >&2
    exit 1
  fi
}

validate_exception_state

if [[ "${mode}" != "tidy" ]]; then
  check_tool clang-format-22
  (
    cd "${repo_root}"
    clang-format-22 --style=file --dump-config >/dev/null
  )
fi

if [[ "${mode}" != "format" ]]; then
  check_tool clang-tidy-22
  clang-tidy-22 \
    --verify-config \
    --config-file="${repo_root}/.clang-tidy"
fi

if ((${#files[@]} == 0)); then
  echo "C++ style gate: PASS (configuration valid; no covered C++ files)"
  exit 0
fi

if [[ "${mode}" != "tidy" ]]; then
  (
    cd "${repo_root}"
    clang-format-22 --dry-run --Werror --style=file "${files[@]}"
  )
fi

if [[ "${mode}" != "format" ]]; then
  declare -a translation_units=()
  declare -a headers=()
  for file in "${files[@]}"; do
    if is_translation_unit "${file}"; then
      translation_units+=("${file}")
    else
      headers+=("${file}")
    fi
  done
  if ((${#headers[@]})); then
    echo "C++ style gate: header lint coverage requires an explicitly mapped translation unit; not verified" >&2
    exit 2
  fi
  if ((${#translation_units[@]})); then
    if [[ ! -f "${compile_commands_dir}/compile_commands.json" ]]; then
      echo "C++ style gate: missing compilation database: ${compile_commands_dir}/compile_commands.json" >&2
      exit 2
    fi
    (
      cd "${repo_root}"
      clang-tidy-22 \
        --config-file="${repo_root}/.clang-tidy" \
        --warnings-as-errors='*' \
        -p="${compile_commands_dir}" \
        "${translation_units[@]}"
    )
  fi
fi

echo "C++ style gate: PASS (${#files[@]} covered file(s))"
