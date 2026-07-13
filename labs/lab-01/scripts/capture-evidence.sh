#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/common.sh"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="${REPO_ROOT}/evidence/lab-01/${STAMP}"
mkdir -p "${OUT}"

k -n "${DATA_NAMESPACE}" get pods,pvc,ingress -o wide >"${OUT}/data-platform.txt"
k -n "${DATA_NAMESPACE}" exec "${POSTGRES_POD}" -- \
  psql -U supportops -d supportops -c \
  'SELECT category, count(*) FROM helpdesk.tickets GROUP BY category ORDER BY category;' \
  >"${OUT}/postgres-summary.txt"
python3 "${REPO_ROOT}/datasets/verify_supportops.py" "${DATASET}" >"${OUT}/dataset-quality.txt"
(cd "${REPO_ROOT}" && .venv/bin/dvc status --cloud) >"${OUT}/dvc-status.txt"
bash "${REPO_ROOT}/verification/lab-01/verify.sh" >"${OUT}/verification.txt"
log "Evidence written to ${OUT}"
