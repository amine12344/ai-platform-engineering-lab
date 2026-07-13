#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_command kubectl
cluster_exists || fail "Create the cluster before deploying the baseline"
use_context

log "Applying SupportOps namespace ownership boundaries"
kubectl --context "${KUBE_CONTEXT}" apply \
  -f "${REPO_ROOT}/platform/foundation/namespaces.yaml"

log "Applying the platform health desired state"
kubectl --context "${KUBE_CONTEXT}" apply \
  -f "${REPO_ROOT}/platform/foundation/platform-health.yaml"

kubectl --context "${KUBE_CONTEXT}" -n "${HEALTH_NAMESPACE}" rollout status \
  "deployment/${HEALTH_DEPLOYMENT}" --timeout=180s

log "SupportOps baseline desired state is ready"
