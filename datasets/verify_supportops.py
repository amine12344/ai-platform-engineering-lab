#!/usr/bin/env python3
"""Validate the contract for a SupportOps synthetic helpdesk release."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import sys
from datetime import datetime
from pathlib import Path

from generate_supportops import CATEGORIES, FIELDS, PRIORITIES


def fail(message: str) -> None:
    print(f"FAIL  {message}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("path", nargs="?", type=Path, default=Path("datasets/releases/sample/tickets.csv"))
    parser.add_argument("--rows", type=int, default=250)
    args = parser.parse_args()
    if not args.path.is_file():
        fail(f"dataset does not exist: {args.path}")

    manifest_path = Path(__file__).parent / "releases" / "sample" / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    digest = hashlib.sha256(args.path.read_bytes()).hexdigest()
    if args.rows == manifest["rows"] and digest != manifest["sha256"]:
        fail(f"content hash differs from release manifest: {digest}")

    with args.path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != FIELDS:
            fail(f"schema differs from canonical fields: {reader.fieldnames}")
        records = list(reader)

    if len(records) != args.rows:
        fail(f"expected {args.rows} rows; observed {len(records)}")
    ids = [record["ticket_id"] for record in records]
    if len(ids) != len(set(ids)):
        fail("ticket_id contains duplicates")

    for number, record in enumerate(records, start=2):
        try:
            created = datetime.fromisoformat(record["created_at"].replace("Z", "+00:00"))
            resolved = datetime.fromisoformat(record["resolved_at"].replace("Z", "+00:00"))
            score = int(record["satisfaction_score"])
            minutes = int(record["resolution_minutes"])
        except (TypeError, ValueError) as exc:
            fail(f"row {number} contains an invalid typed value: {exc}")
        if resolved <= created or minutes <= 0:
            fail(f"row {number} has an invalid resolution interval")
        if record["priority"] not in PRIORITIES:
            fail(f"row {number} has an invalid priority")
        if record["category"] not in CATEGORIES:
            fail(f"row {number} has an invalid category")
        if record["subcategory"] not in CATEGORIES[record["category"]]:
            fail(f"row {number} has an invalid category/subcategory pair")
        if not 1 <= score <= 5:
            fail(f"row {number} has an invalid satisfaction score")

    print(f"PASS  schema={len(FIELDS)} fields rows={len(records)} unique_ticket_ids={len(set(ids))} sha256={digest}")


if __name__ == "__main__":
    main()
