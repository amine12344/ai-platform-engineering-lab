#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_command kubectl
require_command curl
cluster_exists || fail "The Lab 0 cluster does not exist"

evidence_directory="${REPO_ROOT}/evidence/lab-00"
mkdir -p "${evidence_directory}"

{
  printf 'captured_at_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'kind_version=%s\n' "$(kind version)"
  printf 'kubernetes_version=%s\n' \
    "$(kubectl --context "${KUBE_CONTEXT}" version -o yaml | awk '/gitVersion:/ {print $2; exit}')"
  printf 'registry_image=%s\n' "${REGISTRY_IMAGE}"
  printf 'ingress_chart_version=%s\n' "${INGRESS_NGINX_CHART_VERSION}"
  printf 'platform_health_image=%s\n' "${PLATFORM_HEALTH_IMAGE}"
} >"${evidence_directory}/versions.txt"

kubectl --context "${KUBE_CONTEXT}" get nodes -o wide \
  >"${evidence_directory}/nodes.txt"
kubectl --context "${KUBE_CONTEXT}" get namespaces --show-labels \
  >"${evidence_directory}/namespaces.txt"
kubectl --context "${KUBE_CONTEXT}" -n "${HEALTH_NAMESPACE}" get \
  deployment,service,ingress,pods -o wide \
  >"${evidence_directory}/platform-health.txt"
curl -fsS -H "Host: ${HEALTH_HOST}" http://127.0.0.1/healthz \
  >"${evidence_directory}/endpoint-health.txt"

log "Captured machine-readable evidence in ${evidence_directory}"
