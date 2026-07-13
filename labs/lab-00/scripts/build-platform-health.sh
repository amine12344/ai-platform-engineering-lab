#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

for command_name in curl docker; do
  require_command "${command_name}"
done

curl -fsS "http://127.0.0.1:${REGISTRY_PORT}/v2/" >/dev/null \
  || fail "Local registry is not reachable; run make create-cluster"

log "Building ${PLATFORM_HEALTH_IMAGE}"
docker build \
  --build-arg "BASE_IMAGE=${PLATFORM_HEALTH_BASE_IMAGE}" \
  --tag "${PLATFORM_HEALTH_IMAGE}" \
  "${REPO_ROOT}/starter-project/platform-health"

log "Pushing the baseline image into the local registry"
docker push "${PLATFORM_HEALTH_IMAGE}"
