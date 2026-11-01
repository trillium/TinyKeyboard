#!/bin/bash
# make stable-install: build the current commit for the captain's iPhone and
# install it with devicectl, over Tailscale, with no link and no tap.
#
#   make ship-gate && make stable-install
#
# REFUSES unless `make ship-gate` left build/ship-pass/<HEAD sha>.json. The
# phone is reached through scripts/phone-session.sh (lock + phone-reach), so
# this script works on any network the phone is on. Never uploads anything.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source-path=SCRIPTDIR source=phone-lib.sh
. "$ROOT/scripts/phone-lib.sh"

SHIP_PASS_DIR="${SHIP_PASS_DIR:-$ROOT/build/ship-pass}"
head_sha="$(git -C "$ROOT" rev-parse HEAD)"
[ -f "$SHIP_PASS_DIR/$head_sha.json" ] \
  || phone_die "no ship-gate pass for HEAD ${head_sha:0:7}; run 'make ship-gate' first"

# Not yet in a phone session: take the lock and the device by re-running under one.
if ! phone_in_session; then
  exec "$ROOT/scripts/phone-session.sh" "$ROOT/scripts/stable-install.sh" "$@"
fi

DERIVED="${DERIVED_DATA:-$ROOT/build/device}"
BUILD_NUMBER="$(date -u +%Y%m%d%H%M%S)"
echo "==> Building TinyKeyboard $BUILD_NUMBER for $DEVICE_ID"
xcodebuild -project "$ROOT/TinyKeyboard.xcodeproj" -scheme TinyKeyboard -configuration Release \
  -destination "platform=iOS,id=$DEVICE_ID" -derivedDataPath "$DERIVED" \
  -allowProvisioningUpdates -allowProvisioningDeviceRegistration \
  CURRENT_PROJECT_VERSION="$BUILD_NUMBER" build -quiet

APP="$DERIVED/Build/Products/Release-iphoneos/TinyKeyboard.app"
echo "==> Installing $APP"
xcrun devicectl device install app --device "$DEVICE_ID" "$APP"
echo "TinyKeyboard $BUILD_NUMBER (${head_sha:0:7}) installed on $DEVICE_ID at $(date)"
