#!/bin/bash
# Tests for the phone tooling. phone-reach, xcodebuild and xcrun are stubs on
# PATH and the lock lives in a temp dir, so no phone and no real lock is touched.
# shellcheck disable=SC2016,SC2034,SC2015  # check() evals single-quoted assertions; rc/out/sha are read there
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$(mktemp -d "${TMPDIR:-/tmp}/tinykeyboard-phone-test.XXXXXX")"
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin"
export PHONE_LOCK="$T/lock" CALLS="$T/calls" SHIP_PASS_DIR="$T/pass" DERIVED_DATA="$T/dd"
export PATH="$T/bin:$PATH"

# phone-reach prints STUB_DEVICE, or fails when STUB_REACH_FAIL is set.
cat >"$T/bin/phone-reach" <<'STUB'
#!/bin/bash
echo "phone-reach $*" >>"$CALLS"
[ -z "${STUB_REACH_FAIL:-}" ] || { echo "phone-reach: no-tailnet" >&2; exit 1; }
echo "STUB-DEVICE-ID"
STUB
cat >"$T/bin/xcodebuild" <<'STUB'
#!/bin/bash
echo "xcodebuild $*" >>"$CALLS"
STUB
cat >"$T/bin/xcrun" <<'STUB'
#!/bin/bash
echo "xcrun $*" >>"$CALLS"
STUB
chmod +x "$T/bin/"*

fails=0
ok()  { echo "ok   - $1"; }
bad() { echo "FAIL - $1"; fails=$((fails + 1)); }
check() { if eval "$2"; then ok "$1"; else bad "$1"; fi; }

# --- phone-session -----------------------------------------------------------
: >"$CALLS"
out="$("$ROOT/scripts/phone-session.sh" bash -c 'echo "id=$DEVICE_ID lock=$(test -d "$PHONE_LOCK" && echo held)"' 2>&1)"
check "session gives the command the device from phone-reach and holds the lock" '[ "$out" = "id=STUB-DEVICE-ID lock=held" ]'
check "session releases the lock" '[ ! -e "$PHONE_LOCK" ]'
check "session asks phone-reach to wait 120s" 'grep -qx "phone-reach --wait 120" "$CALLS"'

out="$(make -s -C "$ROOT" phone-session CMD='echo "id=$DEVICE_ID"' 2>&1)"
check "make phone-session CMD='...' passes \$DEVICE_ID through to the command" '[ "$out" = "id=STUB-DEVICE-ID" ]'

: >"$CALLS"
"$ROOT/scripts/phone-session.sh" bash -c 'exit 7' >/dev/null 2>&1; rc=$?
check "session exits with the command's status" '[ "$rc" = 7 ]'

: >"$CALLS"
STUB_REACH_FAIL=1 "$ROOT/scripts/phone-session.sh" bash -c "echo ran >>$T/ran" >/dev/null 2>&1; rc=$?
check "unreachable phone: exit 1, command never runs" '[ "$rc" = 1 ] && [ ! -e "$T/ran" ]'
check "unreachable phone: lock released" '[ ! -e "$PHONE_LOCK" ]'

mkdir "$PHONE_LOCK"; echo "$$" >"$PHONE_LOCK/pid"; : >"$CALLS"
"$ROOT/scripts/phone-session.sh" true >/dev/null 2>&1; rc=$?
check "lock held by a live process: refused, phone-reach never called" '[ "$rc" != 0 ] && [ ! -s "$CALLS" ] && [ -d "$PHONE_LOCK" ]'
echo 999999 >"$PHONE_LOCK/pid"
"$ROOT/scripts/phone-session.sh" true >/dev/null 2>&1; rc=$?
check "stale lock is reclaimed" '[ "$rc" = 0 ] && [ ! -e "$PHONE_LOCK" ]'
mkdir -p "$T/racebin" "$PHONE_LOCK"; echo 999999 >"$PHONE_LOCK/pid"; : >"$CALLS"
cat >"$T/racebin/mv" <<STUB
#!/bin/bash
echo $$ >"\$PHONE_LOCK/pid"
exec /bin/mv "\$@"
STUB
chmod +x "$T/racebin/mv"
PATH="$T/racebin:$PATH" "$ROOT/scripts/phone-session.sh" true >/dev/null 2>&1; rc=$?
check "lock retaken by a live holder mid-reclaim is refused and kept" '[ "$rc" != 0 ] && [ ! -s "$CALLS" ] && [ "$(cat "$PHONE_LOCK/pid")" = $$ ]'
rm -rf "$PHONE_LOCK" "$PHONE_LOCK".stale.*
mkdir "$PHONE_LOCK"; : >"$CALLS"
"$ROOT/scripts/phone-session.sh" true >/dev/null 2>&1; rc=$?
check "lock with no pid yet is never reclaimed" '[ "$rc" != 0 ] && [ ! -s "$CALLS" ] && [ -d "$PHONE_LOCK" ]'
rm -rf "$PHONE_LOCK"
"$ROOT/scripts/phone-session.sh" bash -c 'echo 999999 >"$PHONE_LOCK/pid"' >/dev/null 2>&1
check "session never releases a lock that is no longer its own" '[ "$(cat "$PHONE_LOCK/pid")" = 999999 ]'
rm -rf "$PHONE_LOCK"

# --- stable-install ----------------------------------------------------------
# Run from a scratch repo holding the phone scripts, so its tree state is the test's.
inst="$T/inst"; mkdir -p "$inst/scripts"
cp "$ROOT/scripts/phone-lib.sh" "$ROOT/scripts/phone-session.sh" "$ROOT/scripts/stable-install.sh" "$inst/scripts/"
git -C "$inst" init -q && git -C "$inst" add -A && git -C "$inst" -c user.name=t -c user.email=t@t commit -q -m init
: >"$CALLS"
"$inst/scripts/stable-install.sh" >/dev/null 2>&1; rc=$?
check "stable-install refuses without a ship-gate pass, touching nothing" '[ "$rc" != 0 ] && [ ! -s "$CALLS" ]'

mkdir -p "$SHIP_PASS_DIR"; echo '{}' >"$SHIP_PASS_DIR/$(git -C "$inst" rev-parse HEAD).json"
touch "$inst/dirty"; : >"$CALLS"
"$inst/scripts/stable-install.sh" >/dev/null 2>&1; rc=$?
check "stable-install refuses a dirty tree even with a pass for HEAD, touching nothing" '[ "$rc" != 0 ] && [ ! -s "$CALLS" ]'
rm "$inst/dirty"

: >"$CALLS"
"$inst/scripts/stable-install.sh" >/dev/null 2>&1; rc=$?
check "stable-install with a pass succeeds" '[ "$rc" = 0 ]'
check "phone-reach runs before the first xcodebuild/devicectl call" '[ "$(head -1 "$CALLS")" = "phone-reach --wait 120" ]'
check "xcodebuild targets the phone-reach device" 'grep -q "^xcodebuild .*-destination platform=iOS,id=STUB-DEVICE-ID" "$CALLS"'
check "devicectl installs on the phone-reach device" 'grep -q "^xcrun devicectl device install app --device STUB-DEVICE-ID " "$CALLS"'
check "stable-install releases the lock" '[ ! -e "$PHONE_LOCK" ]'

: >"$CALLS"
STUB_REACH_FAIL=1 "$inst/scripts/stable-install.sh" >/dev/null 2>&1; rc=$?
check "stable-install with an unreachable phone builds and installs nothing" '[ "$rc" = 1 ] && ! grep -qE "^(xcodebuild|xcrun)" "$CALLS"'

# --- ship-gate ---------------------------------------------------------------
repo="$T/repo"; mkdir "$repo"
git -C "$repo" init -q && git -C "$repo" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
sha="$(git -C "$repo" rev-parse HEAD)"
export SHIP_ROOT="$repo" SHIP_PASS_DIR="$T/pass2"
SHIP_GATE_CMD=false "$ROOT/scripts/ship-gate.sh" >/dev/null 2>&1; rc=$?
check "ship-gate: failing tests write no pass" '[ "$rc" != 0 ] && [ ! -e "$SHIP_PASS_DIR/$sha.json" ]'
touch "$repo/dirty"
SHIP_GATE_CMD=true "$ROOT/scripts/ship-gate.sh" >/dev/null 2>&1; rc=$?
check "ship-gate: dirty tree refused" '[ "$rc" != 0 ] && [ ! -e "$SHIP_PASS_DIR/$sha.json" ]'
rm "$repo/dirty"
SHIP_GATE_CMD=true "$ROOT/scripts/ship-gate.sh" >/dev/null 2>&1; rc=$?
check "ship-gate: clean tree and green tests write the pass" '[ "$rc" = 0 ] && [ -f "$SHIP_PASS_DIR/$sha.json" ]'
unset SHIP_ROOT

[ "$fails" = 0 ] && echo "all phone tests passed" || { echo "$fails phone test(s) failed"; exit 1; }
