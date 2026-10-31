#!/bin/bash
# Run TinyKeyboard's tests on an iOS simulator.
#
#   scripts/run-tests.sh            # unit tests + UI tests
#   scripts/run-tests.sh unit       # unit tests only (fast, ~1s of test time)
#   scripts/run-tests.sh ui         # UI tests only
#   SIM_NAME="iPhone 17 Pro Max" scripts/run-tests.sh   # another device size
#
# What runs (see TESTING.md for what each layer covers):
#   TinyKeyboardTests    XCTest, hosted in the app: panel state, the extension's
#                        real Auto Layout at 10 widths, Info.plist guarantees.
#   TinyKeyboardUITests  XCUITest: host-app screens, and the real extension
#                        (switch in, panel shows, collapse).
#
# The UI layer needs TinyKeyboard in the simulator's keyboard list and the
# software keyboard showing, so this script adds it via the simulator's
# AppleKeyboards default and reboots the simulator first (XCUITest can flip
# the Mac's hardware keyboard on after the first launch of a boot).
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
WHICH="${1:-all}"
SIM_NAME="${SIM_NAME:-iPhone 17 Pro}"
DERIVED="${DERIVED_DATA:-build/dd}"
EXTENSION_ID="com.trillium.TinyKeyboard.keyboard"

UDID="$(xcrun simctl list devices available | grep -F "    $SIM_NAME (" | head -1 | sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/')"
[ -n "$UDID" ] || { echo "error: no available simulator named '$SIM_NAME' (see: xcrun simctl list devices)" >&2; exit 1; }
DEST="platform=iOS Simulator,id=$UDID"
echo "==> Simulator: $SIM_NAME ($UDID)"

# Runs xcodebuild test for one test bundle, prints a digest, returns its exit status.
xctest() {
  local bundle="$1" log status=0
  log="$(mktemp "${TMPDIR:-/tmp}/tinykeyboard-test.XXXXXX")"
  xcodebuild test -project TinyKeyboard.xcodeproj -scheme TinyKeyboard -destination "$DEST" \
    -derivedDataPath "$DERIVED" -only-testing:"$bundle" CODE_SIGNING_ALLOWED=NO >"$log" 2>&1 || status=$?
  grep -E "Test Case .*(passed|failed)|Test skipped|Executed|error:|TEST (SUCCEEDED|FAILED)" "$log" || true
  [ "$status" -eq 0 ] || echo "xcodebuild failed (exit $status); full log: $log"
  return "$status"
}

run_unit() {
  echo "==> Unit tests"
  xctest TinyKeyboardTests
}

run_ui() {
  echo "==> Preparing simulator keyboards"
  xcrun simctl shutdown "$UDID" 2>/dev/null || true
  xcrun simctl boot "$UDID"
  xcrun simctl bootstatus "$UDID" -b >/dev/null
  xcrun simctl spawn "$UDID" defaults write -g AppleKeyboards -array \
    "en_US@sw=QWERTY;hw=Automatic" "emoji@sw=Emoji" "$EXTENSION_ID"
  # Without this the globe key only cycles QWERTY <-> Emoji and never reaches
  # the extension, so the real-extension UI test silently skips.
  xcrun simctl spawn "$UDID" defaults write -g AppleKeyboardsExpanded -bool true
  xcrun simctl shutdown "$UDID"
  xcrun simctl boot "$UDID"
  xcrun simctl bootstatus "$UDID" -b >/dev/null
  echo "==> UI tests"
  xctest TinyKeyboardUITests
}

case "$WHICH" in
  unit) run_unit ;;
  ui)   run_ui ;;
  all)  run_unit && run_ui ;;
  *)    echo "usage: $0 [unit|ui|all]" >&2; exit 2 ;;
esac
