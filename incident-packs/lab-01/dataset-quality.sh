#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
DATASET="${REPO_ROOT}/datasets/releases/sample/tickets.csv"

case "${1:-}" in
  inject)
    [[ -f "${DATASET}" ]] || { echo "Generate the dataset first" >&2; exit 1; }
    python3 - "${DATASET}" <<'PY'
import csv, pathlib, sys
path = pathlib.Path(sys.argv[1])
with path.open(newline='', encoding='utf-8') as handle:
    rows = list(csv.DictReader(handle))
fields = list(rows[0])
rows[0]['priority'] = 'URGENT'
with path.open('w', newline='', encoding='utf-8') as handle:
    writer = csv.DictWriter(handle, fieldnames=fields, lineterminator='\n')
    writer.writeheader(); writer.writerows(rows)
print('Injected incident: SUP-000001 now has an invalid priority.')
PY
    ;;
  recover)
    cd "${REPO_ROOT}"
    python3 datasets/generate_supportops.py
    python3 datasets/verify_supportops.py
    ;;
  *)
    echo "usage: $0 inject|recover" >&2
    exit 2
    ;;
esac
