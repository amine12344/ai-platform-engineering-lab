#!/usr/bin/env bash

source "$(dirname "$0")/common.sh"
require_command docker

for image in "${SEAWEEDFS_IMAGE}" "${POSTGRES_IMAGE}"; do
  log "Caching ${image}"
  docker pull "${image}"
done

if command -v kind >/dev/null 2>&1 && kind get clusters 2>/dev/null | grep -Fxq supportops-ai; then
  kind load docker-image --name supportops-ai "${SEAWEEDFS_IMAGE}" "${POSTGRES_IMAGE}"
fi
