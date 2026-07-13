#!/usr/bin/env python3
"""Validate a SupportOps Synthetic IT Helpdesk Dataset release."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import sys
from datetime import datetime
from pathlib import Path

from generate_supportops import (
    CATEGORY_PRODUCTS,
    CHANNELS,
    CUSTOMER_TIERS,
    FIELDS,
    LANGUAGES,
    PRIORITIES,
)


def validate_dataset(
    path: Path, expected_rows: int, expected_sha256: str | None = None
) -> dict[str, int | str]:
    """Validate one release and return concise evidence or raise ValueError."""
    if not path.is_file():
        raise ValueError(f"dataset does not exist: {path}")
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    if expected_sha256 is not None and digest != expected_sha256:
        raise ValueError(f"content hash differs from release manifest: {digest}")

    with path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != FIELDS:
            raise ValueError(f"schema differs from canonical fields: {reader.fieldnames}")
        records = list(reader)

    if len(records) != expected_rows:
        raise ValueError(f"expected {expected_rows} rows; observed {len(records)}")
    identifiers = [record["ticket_id"] for record in records]
    if len(identifiers) != len(set(identifiers)):
        raise ValueError("ticket_id contains duplicates")

    for number, record in enumerate(records, start=2):
        try:
            datetime.fromisoformat(record["created_at"].replace("Z", "+00:00"))
            satisfaction = int(record["satisfaction_score"])
            resolution_minutes = int(record["resolution_time_minutes"])
        except (TypeError, ValueError) as exc:
            raise ValueError(f"row {number} contains an invalid typed value: {exc}") from exc
        if record["priority"] not in PRIORITIES:
            raise ValueError(f"row {number} has an invalid priority")
        if record["category"] not in CATEGORY_PRODUCTS:
            raise ValueError(f"row {number} has an invalid category")
        if record["product"] not in CATEGORY_PRODUCTS[record["category"]]:
            raise ValueError(f"row {number} has an invalid category/product pair")
        if record["channel"] not in CHANNELS or record["language"] not in LANGUAGES:
            raise ValueError(f"row {number} has an invalid channel or language")
        if record["customer_tier"] not in CUSTOMER_TIERS:
            raise ValueError(f"row {number} has an invalid customer tier")
        if record["escalated"] not in {"true", "false"}:
            raise ValueError(f"row {number} has an invalid escalated value")
        if resolution_minutes <= 0 or not 1 <= satisfaction <= 5:
            raise ValueError(f"row {number} violates numeric quality limits")
        if not record["subject"].strip() or not record["body"].strip():
            raise ValueError(f"row {number} is missing ticket content")

    return {
        "schema_fields": len(FIELDS),
        "rows": len(records),
        "unique_ticket_ids": len(set(identifiers)),
        "sha256": digest,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "path", nargs="?", type=Path, default=Path("datasets/releases/sample/tickets.csv")
    )
    parser.add_argument("--rows", type=int, default=250)
    args = parser.parse_args()
    manifest_path = Path(__file__).parent / "releases" / "sample" / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    expected_sha256 = manifest["sha256"] if args.rows == manifest["rows"] else None
    try:
        evidence = validate_dataset(args.path, args.rows, expected_sha256)
    except ValueError as exc:
        print(f"FAIL  {exc}", file=sys.stderr)
        raise SystemExit(1) from exc
    print(
        "PASS  "
        f"schema={evidence['schema_fields']} fields rows={evidence['rows']} "
        f"unique_ticket_ids={evidence['unique_ticket_ids']} sha256={evidence['sha256']}"
    )


if __name__ == "__main__":
    main()
