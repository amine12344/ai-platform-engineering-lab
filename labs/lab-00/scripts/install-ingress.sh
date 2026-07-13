#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

for command_name in docker helm kind kubectl; do
  require_command "${command_name}"
done
cluster_exists || fail "Create the cluster before installing ingress-nginx"

chart="$(chart_archive)"
rendered="$(rendered_ingress_manifest)"
[[ -f "${chart}" && -f "${rendered}" ]] \
  || fail "Cached ingress assets are missing; run make cache-lab-0"

log "Loading cached ingress images into Kind"
while IFS= read -r image; do
  [[ -n "${image}" ]] || continue
  kind load docker-image --name "${CLUSTER_NAME}" "${image}"
done < <(
  awk '/^[[:space:]]*image:/ {gsub(/"/, "", $2); print $2}' "${rendered}" | sort -u
)

use_context
log "Installing ingress-nginx chart ${INGRESS_NGINX_CHART_VERSION}"
helm upgrade --install ingress-nginx "${chart}" \
  --kube-context "${KUBE_CONTEXT}" \
  --namespace ingress-nginx \
  --create-namespace \
  --values "${REPO_ROOT}/platform/foundation/ingress-nginx-values.yaml" \
  --wait \
  --timeout 5m

kubectl --context "${KUBE_CONTEXT}" -n ingress-nginx rollout status \
  deployment/ingress-nginx-controller --timeout=180s

log "ingress-nginx is ready"
