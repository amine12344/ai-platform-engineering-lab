#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck source=../../labs/lab-00/scripts/common.sh
source "${REPO_ROOT}/labs/lab-00/scripts/common.sh"

passed=0
failed=0

check() {
  local description="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    printf 'PASS  %s\n' "${description}"
    passed=$((passed + 1))
  else
    printf 'FAIL  %s\n' "${description}"
    failed=$((failed + 1))
  fi
}

check_endpoint() {
  local attempt response
  for attempt in $(seq 1 30); do
    response="$(curl -fsS -H "Host: ${HEALTH_HOST}" http://127.0.0.1/healthz 2>/dev/null || true)"
    [[ "${response}" == "ok" ]] && return 0
    sleep 2
  done
  return 1
}

check_nodes_ready() {
  kubectl --context "${KUBE_CONTEXT}" get nodes --no-headers \
    | awk 'NF == 0 {exit 1} $2 != "Ready" {exit 1}'
}

check_kind_node_images() {
  local node observed
  for node in $(kind get nodes --name "${CLUSTER_NAME}"); do
    observed="$(docker inspect -f '{{.Config.Image}}' "${node}")"
    [[ "${observed}" == "${KIND_NODE_IMAGE}" ]] || return 1
  done
}

check_resource_profile_labels() {
  local observed
  observed="$(kubectl --context "${KUBE_CONTEXT}" get nodes \
    -o go-template='{{range .items}}{{index .metadata.labels "supportops.io/resource-profile"}}{{"\n"}}{{end}}')"
  [[ -n "${observed}" ]] || return 1
  while IFS= read -r profile; do
    [[ "${profile}" =~ ^(16gb|24gb|32gb)$ ]] || return 1
  done <<<"${observed}"
}

check_registry_image() {
  [[ "$(docker inspect -f '{{.Config.Image}}' "${REGISTRY_NAME}")" == "${REGISTRY_IMAGE}" ]]
}

check_ingress_image() {
  local observed
  observed="$(kubectl --context "${KUBE_CONTEXT}" -n ingress-nginx \
    get deployment ingress-nginx-controller \
    -o jsonpath='{.spec.template.spec.containers[0].image}')"
  [[ "${observed}" == *":${INGRESS_NGINX_CONTROLLER_VERSION}"* ]]
}

check_namespaces() {
  local namespace
  for namespace in supportops-platform supportops-data supportops-ml \
    supportops-observability supportops-security; do
    kubectl --context "${KUBE_CONTEXT}" get namespace "${namespace}" >/dev/null \
      || return 1
  done
}

check_health_image() {
  local observed
  observed="$(kubectl --context "${KUBE_CONTEXT}" -n "${HEALTH_NAMESPACE}" \
    get deployment "${HEALTH_DEPLOYMENT}" \
    -o jsonpath='{.spec.template.spec.containers[0].image}')"
  [[ "${observed}" == "${PLATFORM_HEALTH_IMAGE}" ]]
}

printf 'Lab 0 verification — SupportOps trusted local baseline\n\n'

check "Kind cluster exists" cluster_exists
check "Kind nodes use the pinned image" check_kind_node_images
check "Docker Registry v2 responds" curl -fsS "http://127.0.0.1:${REGISTRY_PORT}/v2/"
check "Registry container uses the pinned v2 image" check_registry_image
check "Kubernetes nodes are Ready" check_nodes_ready
check "Nodes carry a supported resource-profile label" check_resource_profile_labels
check "SupportOps namespaces exist" check_namespaces
check "Local-registry discovery ConfigMap exists" \
  kubectl --context "${KUBE_CONTEXT}" -n kube-public get configmap local-registry-hosting
check "ingress-nginx controller is available" \
  kubectl --context "${KUBE_CONTEXT}" -n ingress-nginx rollout status \
    deployment/ingress-nginx-controller --timeout=5s
check "ingress-nginx controller uses the pinned release" check_ingress_image
check "Platform health deployment is available" \
  kubectl --context "${KUBE_CONTEXT}" -n "${HEALTH_NAMESPACE}" rollout status \
    "deployment/${HEALTH_DEPLOYMENT}" --timeout=5s
check "Platform health uses the local registry image" check_health_image
check "Platform health Service exists" \
  kubectl --context "${KUBE_CONTEXT}" -n "${HEALTH_NAMESPACE}" get service platform-health
check "Platform health Ingress exists" \
  kubectl --context "${KUBE_CONTEXT}" -n "${HEALTH_NAMESPACE}" get ingress platform-health
check "Ingress health endpoint returns ok" check_endpoint

printf '\nResult: %s passed, %s failed\n' "${passed}" "${failed}"
[[ "${failed}" -eq 0 ]]
