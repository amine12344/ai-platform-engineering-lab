#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_command docker
require_command kind

scope="${1:-cluster}"

if cluster_exists; then
  log "Deleting Kind cluster ${CLUSTER_NAME}"
  kind delete cluster --name "${CLUSTER_NAME}"
else
  log "Kind cluster ${CLUSTER_NAME} is already absent"
fi

if [[ "${scope}" == "all" ]]; then
  if docker container inspect "${REGISTRY_NAME}" >/dev/null 2>&1; then
    log "Deleting local registry container ${REGISTRY_NAME}"
    docker rm -f "${REGISTRY_NAME}" >/dev/null
  fi
  if docker volume inspect "${REGISTRY_VOLUME}" >/dev/null 2>&1; then
    log "Deleting registry volume ${REGISTRY_VOLUME}"
    docker volume rm "${REGISTRY_VOLUME}" >/dev/null
  fi
fi
