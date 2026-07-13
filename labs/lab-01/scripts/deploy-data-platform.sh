#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/common.sh"
require_command kubectl
require_command getent
[[ -x "${REPO_ROOT}/.venv/bin/python" ]] || fail "Run make install-lab-1-tools first"
getent hosts "${S3_HOST}" | grep -q '127\.0\.0\.1' \
  || fail "Map ${S3_HOST} to 127.0.0.1 in /etc/hosts before deployment"

k get namespace "${DATA_NAMESPACE}" >/dev/null || fail "Run Lab 0 before Lab 1"

SECRET_DIR="${REPO_ROOT}/.local/lab-01"
SECRET_FILE="${SECRET_DIR}/postgres-password"
S3_ACCESS_FILE="${SECRET_DIR}/s3-access-key"
S3_SECRET_FILE="${SECRET_DIR}/s3-secret-key"
S3_CONFIG_FILE="${SECRET_DIR}/s3.json"
mkdir -p "${SECRET_DIR}"
if [[ ! -s "${SECRET_FILE}" ]]; then
  umask 077
  python3 - <<'PY' >"${SECRET_FILE}"
import secrets
print(secrets.token_urlsafe(32))
PY
fi
if [[ ! -s "${S3_ACCESS_FILE}" || ! -s "${S3_SECRET_FILE}" ]]; then
  umask 077
  printf 'supportops-%s\n' "$(python3 -c 'import secrets; print(secrets.token_hex(8))')" >"${S3_ACCESS_FILE}"
  python3 -c 'import secrets; print(secrets.token_urlsafe(32))' >"${S3_SECRET_FILE}"
fi
python3 - "${S3_ACCESS_FILE}" "${S3_SECRET_FILE}" "${S3_CONFIG_FILE}" <<'PY'
import json, pathlib, sys
access = pathlib.Path(sys.argv[1]).read_text().strip()
secret = pathlib.Path(sys.argv[2]).read_text().strip()
config = {"identities": [{"name": "supportops-dvc", "credentials": [{
    "accessKey": access, "secretKey": secret}],
    "actions": ["Read", "Write", "List", "Tagging", "Admin"]}]}
pathlib.Path(sys.argv[3]).write_text(json.dumps(config), encoding="utf-8")
PY

log "Applying a generated Kubernetes Secret without storing it in Git"
k -n "${DATA_NAMESPACE}" create secret generic postgresql-credentials \
  --from-literal=password="$(<"${SECRET_FILE}")" \
  --dry-run=client -o yaml | k apply -f -
k -n "${DATA_NAMESPACE}" create secret generic seaweedfs-s3-credentials \
  --from-file=s3.json="${S3_CONFIG_FILE}" \
  --dry-run=client -o yaml | k apply -f -

log "Applying SeaweedFS and PostgreSQL desired state"
k apply -f "${REPO_ROOT}/platform/data/seaweedfs.yaml"
k apply -f "${REPO_ROOT}/platform/data/postgresql.yaml"
k -n "${DATA_NAMESPACE}" rollout status statefulset/seaweedfs --timeout=240s
k -n "${DATA_NAMESPACE}" rollout status statefulset/postgresql --timeout=240s

log "Creating the DVC object bucket through the S3-compatible endpoint"
AWS_ACCESS_KEY_ID="$(<"${S3_ACCESS_FILE}")" \
AWS_SECRET_ACCESS_KEY="$(<"${S3_SECRET_FILE}")" \
  "${REPO_ROOT}/.venv/bin/python" - "${S3_HOST}" "${S3_BUCKET}" <<'PY'
import boto3, sys
client = boto3.client("s3", endpoint_url=f"http://{sys.argv[1]}")
bucket = sys.argv[2]
if bucket not in [item["Name"] for item in client.list_buckets().get("Buckets", [])]:
    client.create_bucket(Bucket=bucket)
client.head_bucket(Bucket=bucket)
PY
