#!/bin/bash
# Build a Release .xcarchive of TinyKeyboard for App Store distribution.
#
# This ONLY archives. It never uploads and never submits: uploading is a
# captain step (see Plans/submission/CAPTAIN_CHECKLIST.md).
#
#   scripts/archive-release.sh
#   TEAM_ID=XXXXXXXXXX scripts/archive-release.sh
#   ALLOW_PROVISIONING_UPDATES=1 scripts/archive-release.sh   # let Xcode create profiles
#
# Output: build/archive/TinyKeyboard.xcarchive
#
# The project file still carries the OTA/ad-hoc team (TV2582LRYN, used by
# ota-publish.sh); the App Store team is passed on the command line so the OTA
# flow keeps working.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
TEAM_ID="${TEAM_ID:-85PWBA3B59}"
ARCHIVE_PATH="${ARCHIVE_PATH:-build/archive/TinyKeyboard.xcarchive}"

args=(archive -project TinyKeyboard.xcodeproj -scheme TinyKeyboard -configuration Release
  -destination 'generic/platform=iOS' -archivePath "$ARCHIVE_PATH"
  DEVELOPMENT_TEAM="$TEAM_ID" ENABLE_USER_SCRIPT_SANDBOXING=NO)
[ "${ALLOW_PROVISIONING_UPDATES:-}" = "1" ] && args+=(-allowProvisioningUpdates)
# CODE_SIGNING_ALLOWED=NO produces an unsigned archive (inspection only; cannot be uploaded).
[ -n "${CODE_SIGNING_ALLOWED:-}" ] && args+=(CODE_SIGNING_ALLOWED="$CODE_SIGNING_ALLOWED")

rm -rf "$ARCHIVE_PATH"
xcodebuild "${args[@]}"
echo "Archive: $PWD/$ARCHIVE_PATH"
