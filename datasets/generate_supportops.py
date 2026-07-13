#!/usr/bin/env python3
"""Generate the deterministic SupportOps synthetic IT helpdesk release."""

from __future__ import annotations

import argparse
import csv
import hashlib
import random
from datetime import datetime, timedelta, timezone
from pathlib import Path

FIELDS = [
    "ticket_id", "created_at", "resolved_at", "channel", "category",
    "subcategory", "priority", "requester_department", "requester_region",
    "assigned_team", "summary", "description", "resolution",
    "satisfaction_score", "resolution_minutes",
]

CATEGORIES = {
    "access": ("password-reset", "mfa", "account-lock"),
    "hardware": ("laptop", "monitor", "peripheral"),
    "network": ("wifi", "vpn", "dns"),
    "software": ("installation", "license", "crash"),
    "collaboration": ("email", "calendar", "video-call"),
}
PRIORITIES = ("P1", "P2", "P3", "P4")
CHANNELS = ("portal", "email", "chat", "phone")
DEPARTMENTS = ("Finance", "Human Resources", "Operations", "Sales", "Engineering")
REGIONS = ("EMEA", "AMER", "APAC")
TEAMS = ("Service Desk", "Identity", "Endpoint", "Network", "Business Apps")


def rows(seed: int, count: int):
    rng = random.Random(seed)
    base = datetime(2026, 1, 5, 8, 0, tzinfo=timezone.utc)
    for index in range(1, count + 1):
        category = rng.choice(tuple(CATEGORIES))
        subcategory = rng.choice(CATEGORIES[category])
        priority = rng.choices(PRIORITIES, weights=(2, 13, 55, 30), k=1)[0]
        duration = rng.randint(8, {"P1": 120, "P2": 360, "P3": 1440, "P4": 2880}[priority])
        created = base + timedelta(minutes=(index - 1) * 47 + rng.randint(0, 30))
        resolved = created + timedelta(minutes=duration)
        yield {
            "ticket_id": f"SUP-{index:06d}",
            "created_at": created.isoformat().replace("+00:00", "Z"),
            "resolved_at": resolved.isoformat().replace("+00:00", "Z"),
            "channel": rng.choice(CHANNELS),
            "category": category,
            "subcategory": subcategory,
            "priority": priority,
            "requester_department": rng.choice(DEPARTMENTS),
            "requester_region": rng.choice(REGIONS),
            "assigned_team": rng.choice(TEAMS),
            "summary": f"{subcategory.replace('-', ' ').title()} support request",
            "description": f"User reports a {subcategory.replace('-', ' ')} issue affecting normal work.",
            "resolution": f"SupportOps validated and resolved the {subcategory.replace('-', ' ')} issue.",
            "satisfaction_score": rng.randint(1, 5),
            "resolution_minutes": duration,
        }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--seed", type=int, default=20260713)
    parser.add_argument("--rows", type=int, default=250)
    parser.add_argument("--output", type=Path, default=Path("datasets/releases/sample/tickets.csv"))
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDS, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows(args.seed, args.rows))
    digest = hashlib.sha256(args.output.read_bytes()).hexdigest()
    print(f"generated={args.output} rows={args.rows} seed={args.seed} sha256={digest}")


if __name__ == "__main__":
    main()
