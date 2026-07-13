#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

for command_name in docker helm kind; do
  require_command "${command_name}"
done

docker info >/dev/null 2>&1 || fail "Docker is not reachable"

mkdir -p "${REPO_ROOT}/.cache/helm"

log "Caching Kind node, registry, and health-service base images"
docker pull "${KIND_NODE_IMAGE}"
docker pull "${REGISTRY_IMAGE}"
docker pull "${PLATFORM_HEALTH_BASE_IMAGE}"

chart="$(chart_archive)"
if [[ ! -f "${chart}" ]]; then
  log "Caching ingress-nginx chart ${INGRESS_NGINX_CHART_VERSION}"
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx --force-update
  helm repo update ingress-nginx
  helm pull ingress-nginx/ingress-nginx \
    --version "${INGRESS_NGINX_CHART_VERSION}" \
    --destination "${REPO_ROOT}/.cache/helm"
else
  log "Using cached chart ${chart}"
fi

rendered="$(rendered_ingress_manifest)"
helm template ingress-nginx "${chart}" \
  --namespace ingress-nginx \
  --values "${REPO_ROOT}/platform/foundation/ingress-nginx-values.yaml" \
  >"${rendered}"

log "Caching images referenced by the rendered ingress manifest"
while IFS= read -r image; do
  [[ -n "${image}" ]] || continue
  docker pull "${image}"
done < <(
  awk '/^[[:space:]]*image:/ {gsub(/"/, "", $2); print $2}' "${rendered}" | sort -u
)

log "Lab 0 dependencies are cached under Docker and .cache/"
