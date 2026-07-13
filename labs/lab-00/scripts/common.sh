#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

export PATH="${REPO_ROOT}/.local/bin:${PATH}"

# shellcheck source=../../../platform/versions.env
source "${REPO_ROOT}/platform/versions.env"

CLUSTER_NAME="supportops-ai"
KUBE_CONTEXT="kind-${CLUSTER_NAME}"
REGISTRY_NAME="supportops-registry"
REGISTRY_PORT="5001"
REGISTRY_VOLUME="supportops-registry-data"
HEALTH_NAMESPACE="supportops-platform"
HEALTH_DEPLOYMENT="platform-health"
HEALTH_HOST="platform.supportops.local"

log() {
  printf '[lab-00] %s\n' "$*"
}

fail() {
  printf '[lab-00] ERROR: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

cluster_exists() {
  kind get clusters 2>/dev/null | grep -Fxq "${CLUSTER_NAME}"
}

use_context() {
  kubectl config use-context "${KUBE_CONTEXT}" >/dev/null
}

chart_archive() {
  printf '%s/.cache/helm/ingress-nginx-%s.tgz\n' \
    "${REPO_ROOT}" "${INGRESS_NGINX_CHART_VERSION}"
}

rendered_ingress_manifest() {
  printf '%s/.cache/ingress-nginx-rendered.yaml\n' "${REPO_ROOT}"
}
