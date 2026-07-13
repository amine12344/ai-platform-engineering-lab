#!/usr/bin/env bash

source "$(dirname "$0")/common.sh"
DVC="${REPO_ROOT}/.venv/bin/dvc"
[[ -x "${DVC}" ]] || fail "Run make install-lab-1-tools first"
[[ -f "${DATASET}" ]] || fail "Run make generate-dataset first"
[[ -s "${REPO_ROOT}/.local/lab-01/s3-access-key" ]] || fail "Run make deploy-data-platform first"
cd "${REPO_ROOT}"

[[ -d .dvc ]] || "${DVC}" init
"${DVC}" remote add --force --default supportops-s3 "s3://${S3_BUCKET}/dvc"
"${DVC}" remote modify supportops-s3 endpointurl "http://${S3_HOST}"
"${DVC}" remote modify supportops-s3 use_ssl false
"${DVC}" remote modify --local supportops-s3 access_key_id "$(<"${REPO_ROOT}/.local/lab-01/s3-access-key")"
"${DVC}" remote modify --local supportops-s3 secret_access_key "$(<"${REPO_ROOT}/.local/lab-01/s3-secret-key")"
"${DVC}" add "${DATASET#${REPO_ROOT}/}"
"${DVC}" push
"${DVC}" status --cloud
log "Dataset content is tracked by DVC and present in ${S3_BUCKET}"
