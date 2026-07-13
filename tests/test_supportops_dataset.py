from __future__ import annotations

import csv
import sys
import tempfile
import unittest
from pathlib import Path

DATASETS_DIR = Path(__file__).parents[1] / "datasets"
sys.path.insert(0, str(DATASETS_DIR))

from generate_supportops import FIELDS, write_dataset  # noqa: E402
from verify_supportops import validate_dataset  # noqa: E402


class SupportOpsDatasetTests(unittest.TestCase):
    def test_generation_is_byte_deterministic(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            first = Path(directory) / "first.csv"
            second = Path(directory) / "second.csv"
            first_hash = write_dataset(first, seed=20260713, count=250)
            second_hash = write_dataset(second, seed=20260713, count=250)
            self.assertEqual(first_hash, second_hash)
            self.assertEqual(first.read_bytes(), second.read_bytes())

    def test_generated_release_matches_canonical_contract(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            dataset = Path(directory) / "tickets.csv"
            write_dataset(dataset, seed=20260713, count=250)
            evidence = validate_dataset(dataset, expected_rows=250)
            self.assertEqual(evidence["schema_fields"], 14)
            self.assertEqual(evidence["rows"], 250)

    def test_invalid_priority_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            dataset = Path(directory) / "tickets.csv"
            write_dataset(dataset, seed=20260713, count=5)
            with dataset.open(newline="", encoding="utf-8") as handle:
                rows = list(csv.DictReader(handle))
            rows[0]["priority"] = "URGENT"
            with dataset.open("w", newline="", encoding="utf-8") as handle:
                writer = csv.DictWriter(handle, fieldnames=FIELDS, lineterminator="\n")
                writer.writeheader()
                writer.writerows(rows)
            with self.assertRaisesRegex(ValueError, "invalid priority"):
                validate_dataset(dataset, expected_rows=5)


if __name__ == "__main__":
    unittest.main()
