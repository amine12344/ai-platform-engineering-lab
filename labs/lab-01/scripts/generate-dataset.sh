#!/usr/bin/env bash

source "$(dirname "$0")/common.sh"
require_command python3
cd "${REPO_ROOT}"
python3 datasets/generate_supportops.py
python3 datasets/verify_supportops.py
