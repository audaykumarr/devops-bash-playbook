#!/usr/bin/env bash
    set -euo pipefail
    IFS=$'
	'

    LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Centralize shared operational primitives here so every script behaves consistently.
# Keep logging, retries, dry-run behavior, and locking in one maintained place.

    timestamp() {
      date -u +"%Y-%m-%dT%H:%M:%SZ"
    }

    _level_to_int() {
      case "$1" in
        DEBUG) echo 10 ;;
        INFO) echo 20 ;;
        WARN) echo 30 ;;
        ERROR) echo 40 ;;
        *) echo 20 ;;
      esac
    }

    log() {
      local level="$1"
      shift
      if [[ "$(_level_to_int "$level")" -lt "$(_level_to_int "$LOG_LEVEL")" ]]; then
        return 0
      fi

      printf '%s [%s] %s
' "$(timestamp)" "$level" "$*" >&2
    }

    die() {
      log ERROR "$*"
      exit 1
    }

    on_error() {
      local line="$1"
      local command="$2"
      local exit_code="${3:-1}"
      log ERROR "command failed at line ${line}: ${command} (exit=${exit_code})"
      exit "$exit_code"
    }

    require_cmd() {
      local command_name
      for command_name in "$@"; do
        command -v "$command_name" >/dev/null 2>&1 || die "required command not found: $command_name"
      done
    }

    ensure_dir() {
      mkdir -p "$1"
    }

    require_root() {
      [[ "$(id -u)" -eq 0 ]] || die "this script must run as root"
    }

    load_env_file() {
      local env_file="${1:-.env}"
      [[ -f "$env_file" ]] || return 0
      set -a
      # shellcheck disable=SC1090
      source "$env_file"
      set +a
    }

    run_cmd() {
      if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log INFO "[dry-run] $*"
        return 0
      fi
      "$@"
    }

    with_retry() {
      local attempts="$1"
      local delay_seconds="$2"
      shift 2

      local attempt=1
      until "$@"; do
        if (( attempt >= attempts )); then
          log ERROR "command failed after ${attempts} attempts: $*"
          return 1
        fi
        log WARN "attempt ${attempt}/${attempts} failed, retrying in ${delay_seconds}s: $*"
        sleep "$delay_seconds"
        attempt=$(( attempt + 1 ))
      done
    }

    acquire_lock() {
      local lock_file="$1"
      exec 9>"$lock_file"
      flock -n 9 || die "another process already holds lock $lock_file"
    }
