#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck source=../../labs/lab-01/scripts/common.sh
source "${REPO_ROOT}/labs/lab-01/scripts/common.sh"

passed=0
failed=0
check() {
  local description="$1"; shift
  if "$@" >/dev/null 2>&1; then
    printf 'PASS  %s\n' "${description}"; passed=$((passed + 1))
  else
    printf 'FAIL  %s\n' "${description}"; failed=$((failed + 1))
  fi
}

postgres_count() {
  [[ "$(k -n "${DATA_NAMESPACE}" exec "${POSTGRES_POD}" -- \
    psql -At -U supportops -d supportops -c 'SELECT count(*) FROM helpdesk.tickets;')" == "250" ]]
}

postgres_constraints() {
  [[ "$(k -n "${DATA_NAMESPACE}" exec "${POSTGRES_POD}" -- \
    psql -At -U supportops -d supportops -c \
    "SELECT count(*) FROM helpdesk.tickets WHERE priority NOT IN ('P1','P2','P3','P4') OR satisfaction_score NOT BETWEEN 1 AND 5 OR resolution_time_minutes <= 0;")" == "0" ]]
}

s3_ready() {
  [[ -x "${REPO_ROOT}/.venv/bin/python" ]] || return 1
  [[ -s "${REPO_ROOT}/.local/lab-01/s3-access-key" ]] || return 1
  AWS_ACCESS_KEY_ID="$(<"${REPO_ROOT}/.local/lab-01/s3-access-key")" \
  AWS_SECRET_ACCESS_KEY="$(<"${REPO_ROOT}/.local/lab-01/s3-secret-key")" \
    "${REPO_ROOT}/.venv/bin/python" - "${S3_HOST}" "${S3_BUCKET}" <<'PY'
import boto3, sys
boto3.client("s3", endpoint_url=f"http://{sys.argv[1]}").head_bucket(Bucket=sys.argv[2])
PY
}

dvc_clean() {
  [[ -x "${REPO_ROOT}/.venv/bin/dvc" ]] || return 1
  cd "${REPO_ROOT}" && .venv/bin/dvc status --cloud | grep -Fq 'Data and pipelines are up to date.'
}

printf 'Lab 1 verification — SupportOps data and artifact platform\n\n'
check "Lab 0 remains healthy" bash "${REPO_ROOT}/verification/lab-00/verify.sh"
check "SeaweedFS StatefulSet is available" k -n "${DATA_NAMESPACE}" rollout status statefulset/seaweedfs --timeout=5s
check "SeaweedFS uses the pinned image" bash -c "[[ \"\$(kubectl --context '${KUBE_CONTEXT}' -n '${DATA_NAMESPACE}' get statefulset seaweedfs -o jsonpath='{.spec.template.spec.containers[0].image}')\" == '${SEAWEEDFS_IMAGE}' ]]"
check "S3-compatible DVC bucket responds" s3_ready
check "PostgreSQL StatefulSet is available" k -n "${DATA_NAMESPACE}" rollout status statefulset/postgresql --timeout=5s
check "PostgreSQL uses the pinned image" bash -c "[[ \"\$(kubectl --context '${KUBE_CONTEXT}' -n '${DATA_NAMESPACE}' get statefulset postgresql -o jsonpath='{.spec.template.spec.containers[0].image}')\" == '${POSTGRES_IMAGE}' ]]"
check "Both data services have persistent claims" bash -c "[[ \"\$(kubectl --context '${KUBE_CONTEXT}' -n '${DATA_NAMESPACE}' get pvc --no-headers | wc -l)\" -ge 2 ]]"
check "Dataset satisfies the canonical 14-field contract" python3 "${REPO_ROOT}/datasets/verify_supportops.py" "${DATASET}"
check "PostgreSQL contains exactly 250 tickets" postgres_count
check "PostgreSQL constraints contain no violations" postgres_constraints
check "DVC remote content is synchronized" dvc_clean

printf '\nResult: %s passed, %s failed\n' "${passed}" "${failed}"
[[ "${failed}" -eq 0 ]]
