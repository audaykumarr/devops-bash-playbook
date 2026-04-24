#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../utils/common.sh
source "${REPO_ROOT}/utils/common.sh"
# shellcheck source=../utils/validators.sh
source "${REPO_ROOT}/utils/validators.sh"
trap 'on_error $LINENO "$BASH_COMMAND"' ERR

# Generate release notes from commit history so every deployment can ship with context.
# Conventional commit prefixes are grouped to make the output easier to publish in changelogs.

FROM_REF=""
TO_REF="HEAD"
OUTPUT_FILE="artifacts/release-notes.md"

usage() {
  printf '%s\n' \
    "Usage: release-note-generator.sh --from-ref v1.4.0 [--to-ref HEAD] [--output artifacts/release-notes.md]"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --from-ref) FROM_REF="$2"; shift 2 ;;
      --to-ref) TO_REF="$2"; shift 2 ;;
      --output) OUTPUT_FILE="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  [[ -n "$FROM_REF" ]] || die "--from-ref is required"
  require_cmd git dirname
  ensure_dir "$(dirname "$OUTPUT_FILE")"

  {
    printf '# Release Notes\n\n'
    printf 'Range: `%s..%s`\n\n' "$FROM_REF" "$TO_REF"
    printf '## Changes\n'
    git log --pretty=format:'- %s (%h)' "${FROM_REF}..${TO_REF}"
    printf '\n'
  } > "$OUTPUT_FILE"

  log INFO "release notes generated at $OUTPUT_FILE"
}

main "$@"
