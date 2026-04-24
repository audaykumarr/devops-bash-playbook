#!/usr/bin/env bash
    set -euo pipefail
    IFS=$'
	'

    # shellcheck source=./common.sh
    source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

# Validate inputs early so scripts fail before making partial infrastructure changes.
# Reuse these helpers instead of open-coding path, URL, or port checks.

    require_env() {
      local missing=()
      local variable_name
      for variable_name in "$@"; do
        [[ -n "${!variable_name:-}" ]] || missing+=("$variable_name")
      done

      (( ${#missing[@]} == 0 )) || die "missing required environment variables: ${missing[*]}"
    }

    require_file() {
      [[ -f "$1" ]] || die "required file not found: $1"
    }

    require_dir() {
      [[ -d "$1" ]] || die "required directory not found: $1"
    }

    validate_port() {
      [[ "$1" =~ ^[0-9]+$ ]] || die "port must be numeric: $1"
      (( "$1" >= 1 && "$1" <= 65535 )) || die "port out of range: $1"
    }

    validate_positive_int() {
      [[ "$1" =~ ^[0-9]+$ ]] || die "value must be a positive integer: $1"
    }

    validate_url() {
      [[ "$1" =~ ^https?:// ]] || die "invalid URL: $1"
    }

    validate_semver() {
      [[ "$1" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+([.-][A-Za-z0-9]+)?$ ]] || die "invalid semantic version: $1"
    }
