#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck source=../../labs/lab-00/scripts/common.sh
source "${REPO_ROOT}/labs/lab-00/scripts/common.sh"

require_command kubectl
cluster_exists || fail "The Lab 0 cluster does not exist"

case "${1:-}" in
  inject)
    log "Injecting a controlled outage by scaling ${HEALTH_DEPLOYMENT} to zero"
    kubectl --context "${KUBE_CONTEXT}" -n "${HEALTH_NAMESPACE}" scale \
      "deployment/${HEALTH_DEPLOYMENT}" --replicas=0
    kubectl --context "${KUBE_CONTEXT}" -n "${HEALTH_NAMESPACE}" wait \
      --for=delete pod -l app.kubernetes.io/name=platform-health --timeout=60s \
      || true
    log "Incident active: the ingress route should now return HTTP 503"
    ;;
  recover)
    log "Recovering by reconciling the repository-owned desired state"
    kubectl --context "${KUBE_CONTEXT}" apply \
      -f "${REPO_ROOT}/platform/foundation/platform-health.yaml"
    kubectl --context "${KUBE_CONTEXT}" -n "${HEALTH_NAMESPACE}" rollout status \
      "deployment/${HEALTH_DEPLOYMENT}" --timeout=180s
    log "Recovery complete"
    ;;
  *)
    fail "Usage: $0 inject|recover"
    ;;
esac
