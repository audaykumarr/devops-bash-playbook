#!/usr/bin/env bash
    set -euo pipefail
    IFS=$'
	'

    # shellcheck source=./common.sh
    source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

# Use retries only around transient operations such as network calls or readiness checks.
# Keep backoff behavior shared so deploy and monitoring scripts handle flakiness the same way.

    with_backoff() {
      local attempts="$1"
      local initial_delay="$2"
      shift 2

      local attempt=1
      local delay="$initial_delay"
      until "$@"; do
        if (( attempt >= attempts )); then
          log ERROR "command failed after exponential backoff: $*"
          return 1
        fi
        log WARN "attempt ${attempt}/${attempts} failed, retrying in ${delay}s"
        sleep "$delay"
        delay=$(( delay * 2 ))
        attempt=$(( attempt + 1 ))
      done
    }

    wait_for_http_ok() {
      local url="$1"
      local attempts="$2"
      local delay="$3"
      local status_code=""

      local attempt
      for attempt in $(seq 1 "$attempts"); do
        status_code="$(curl -ksS -o /dev/null -w '%{http_code}' "$url" || true)"
        if [[ "$status_code" =~ ^2|3 ]]; then
          log INFO "endpoint healthy: $url (status=$status_code)"
          return 0
        fi
        log WARN "endpoint unhealthy on attempt ${attempt}/${attempts}: $url (status=${status_code:-n/a})"
        sleep "$delay"
      done

      return 1
    }
