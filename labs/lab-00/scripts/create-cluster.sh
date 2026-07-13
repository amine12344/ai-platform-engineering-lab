#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

for command_name in docker kind kubectl; do
  require_command "${command_name}"
done

profile="${PROFILE:-16gb}"
profile_file="${REPO_ROOT}/platform/kind/profiles/${profile}.yaml"
[[ -f "${profile_file}" ]] || fail "Unknown PROFILE=${profile}; choose 16gb, 24gb, or 32gb"

docker info >/dev/null 2>&1 || fail "Docker is not reachable"

if docker container inspect "${REGISTRY_NAME}" >/dev/null 2>&1; then
  if [[ "$(docker inspect -f '{{.State.Running}}' "${REGISTRY_NAME}")" != "true" ]]; then
    log "Starting the existing local registry"
    docker start "${REGISTRY_NAME}" >/dev/null
  fi
else
  log "Creating the persistent local registry"
  docker volume create "${REGISTRY_VOLUME}" >/dev/null
  docker run -d --restart=always \
    -p "127.0.0.1:${REGISTRY_PORT}:5000" \
    --name "${REGISTRY_NAME}" \
    -v "${REGISTRY_VOLUME}:/var/lib/registry" \
    "${REGISTRY_IMAGE}" >/dev/null
fi

if cluster_exists; then
  log "Kind cluster ${CLUSTER_NAME} already exists; preserving it"
else
  log "Creating ${CLUSTER_NAME} with the ${profile} profile"
  kind create cluster \
    --name "${CLUSTER_NAME}" \
    --image "${KIND_NODE_IMAGE}" \
    --config "${profile_file}" \
    --wait 180s
fi

if ! docker inspect -f '{{json .NetworkSettings.Networks.kind}}' "${REGISTRY_NAME}" 2>/dev/null \
  | grep -q 'IPAddress'; then
  log "Connecting the registry to the Kind network"
  docker network connect kind "${REGISTRY_NAME}"
fi

log "Configuring containerd to resolve localhost:${REGISTRY_PORT} through ${REGISTRY_NAME}"
for node in $(kind get nodes --name "${CLUSTER_NAME}"); do
  registry_directory="/etc/containerd/certs.d/localhost:${REGISTRY_PORT}"
  docker exec "${node}" mkdir -p "${registry_directory}"
  cat <<EOF | docker exec -i "${node}" sh -c "cat > '${registry_directory}/hosts.toml'"
[host."http://${REGISTRY_NAME}:5000"]
  capabilities = ["pull", "resolve", "push"]
EOF
done

use_context

cat <<EOF | kubectl --context "${KUBE_CONTEXT}" apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${REGISTRY_PORT}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

kubectl --context "${KUBE_CONTEXT}" wait \
  --for=condition=Ready nodes --all --timeout=180s

log "Cluster and local registry are ready"
