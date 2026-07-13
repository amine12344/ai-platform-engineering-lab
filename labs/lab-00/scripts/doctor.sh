#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

missing=0

check_command() {
  local command_name="$1"
  if command -v "${command_name}" >/dev/null 2>&1; then
    printf 'PASS  %-12s %s\n' "${command_name}" "$(command -v "${command_name}")"
  else
    printf 'FAIL  %-12s not found\n' "${command_name}"
    missing=1
  fi
}

log "Checking the Lab 0 workstation contract"

for command_name in docker kubectl helm make git curl sha256sum kind; do
  check_command "${command_name}"
done

if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    printf 'PASS  %-12s engine reachable\n' "docker"
  else
    printf 'FAIL  %-12s engine is not reachable\n' "docker"
    missing=1
  fi
fi

if [[ -r /proc/version ]] && grep -qi microsoft /proc/version; then
  printf 'PASS  %-12s detected\n' "WSL"
else
  printf 'INFO  %-12s Linux is supported; WSL 2 is recommended on Windows\n' "WSL"
fi

for profile in 16gb 24gb 32gb; do
  [[ -f "${REPO_ROOT}/platform/kind/profiles/${profile}.yaml" ]] \
    || fail "Missing resource profile: ${profile}"
done
printf 'PASS  %-12s 16gb, 24gb, and 32gb definitions found\n' "profiles"

if [[ "${missing}" -ne 0 ]]; then
  fail "Prerequisite checks failed. Install missing tools and rerun make doctor."
fi

log "Workstation prerequisites are ready"
