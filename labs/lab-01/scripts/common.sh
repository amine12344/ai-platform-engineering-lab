#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

export PATH="${REPO_ROOT}/.local/bin:${PATH}"
# shellcheck source=../../../platform/versions.env
source "${REPO_ROOT}/platform/versions.env"

KUBE_CONTEXT="kind-supportops-ai"
DATA_NAMESPACE="supportops-data"
DATASET="${REPO_ROOT}/datasets/releases/sample/tickets.csv"
S3_HOST="s3.supportops.local"
S3_BUCKET="supportops-dvc"
POSTGRES_POD="postgresql-0"

log() { printf '[lab-01] %s\n' "$*"; }
fail() { printf '[lab-01] ERROR: %s\n' "$*" >&2; exit 1; }
require_command() { command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"; }
k() { kubectl --context "${KUBE_CONTEXT}" "$@"; }
