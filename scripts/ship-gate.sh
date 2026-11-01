#!/bin/bash
# make ship-gate: prove HEAD is safe to put on the captain's iPhone. It passes
# only if the working tree is clean and the full test run (make check, then the
# simulator UI tests) is green, and then writes build/ship-pass/<HEAD sha>.json,
# which `make stable-install` requires. It never touches the phone.
# SHIP_ROOT / SHIP_PASS_DIR / SHIP_GATE_CMD exist so the tests can aim it at a scratch repo.
set -euo pipefail

ROOT="${SHIP_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SHIP_PASS_DIR="${SHIP_PASS_DIR:-$ROOT/build/ship-pass}"
GATE_CMD="${SHIP_GATE_CMD:-make check && scripts/run-tests.sh ui}"

[ -z "$(git -C "$ROOT" status --porcelain)" ] || { echo "ship gate: working tree is not clean; commit or remove changes first" >&2; exit 1; }
head_sha="$(git -C "$ROOT" rev-parse HEAD)"
echo "gate 1/2: HEAD ${head_sha:0:7}, tree clean"

echo "gate 2/2: $GATE_CMD"
( cd "$ROOT" && bash -c "$GATE_CMD" ) || { echo "ship gate: tests failed" >&2; exit 1; }

mkdir -p "$SHIP_PASS_DIR"
printf '{"commit":"%s","passed_at":"%s"}\n' "$head_sha" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >"$SHIP_PASS_DIR/$head_sha.json"
echo "ship gate: PASS for ${head_sha:0:7}"
