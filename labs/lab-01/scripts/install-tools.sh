#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/common.sh"
require_command python3

VENV="${REPO_ROOT}/.venv"
log "Creating the repository-local Python environment"
python3 -m venv "${VENV}"
"${VENV}/bin/python" -m pip install --cache-dir "${REPO_ROOT}/.cache/pip" --upgrade pip
"${VENV}/bin/python" -m pip install --cache-dir "${REPO_ROOT}/.cache/pip" "dvc[s3]==${DVC_VERSION}"
log "DVC $("${VENV}/bin/dvc" --version) is ready"
