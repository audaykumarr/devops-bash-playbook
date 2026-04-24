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

# Parse and validate inputs before mutating infrastructure state.
# Keep side effects inside dedicated functions so failures stay easier to reason about.

    SSHD_CONFIG="/etc/ssh/sshd_config"

    audit_setting() {
      local key="$1"
      local expected="$2"
      local actual
      actual="$(awk -v target="$key" '$1 == target {value=$2} END {print value}' "$SSHD_CONFIG")"
      if [[ "$actual" == "$expected" ]]; then
        log INFO "PASS $key=$actual"
      else
        log WARN "FAIL $key expected=$expected actual=${actual:-unset}"
      fi
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --config) SSHD_CONFIG="$2"; shift 2 ;;
          -h|--help)
            echo "Usage: ssh-hardening-audit.sh [--config /etc/ssh/sshd_config]"
            exit 0
            ;;
          *)
            die "unknown argument: $1"
            ;;
        esac
      done

      require_file "$SSHD_CONFIG"
      require_cmd awk
      audit_setting PermitRootLogin no
      audit_setting PasswordAuthentication no
      audit_setting PubkeyAuthentication yes
      audit_setting X11Forwarding no
      audit_setting MaxAuthTries 4
      audit_setting ClientAliveInterval 300
    }

    main "$@"
