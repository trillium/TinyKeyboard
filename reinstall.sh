#!/bin/bash
# NOT THE INSTALL PATH. Legacy USB/devicectl developer helper, kept only for
# local debugging. Never use it to put the app on the captain's iPhone: the one
# install path is OTA over Tailscale (./ota-publish.sh — see AGENTS.md,
# "OTA install over Tailscale").
set -e

PROJECT_DIR="/Users/trilliumsmith/code/TinyKeyboard"
DEVICE_ID="00008150-000509C03442401C"
APP_PATH="$HOME/Library/Developer/Xcode/DerivedData/TinyKeyboard-czbvieqfncxyzvhhwyaaqvygdmvb/Build/Products/Debug-iphoneos/TinyKeyboard.app"

cd "$PROJECT_DIR"

xcodebuild -project TinyKeyboard.xcodeproj \
  -scheme TinyKeyboard \
  -destination "platform=iOS,id=$DEVICE_ID" \
  -allowProvisioningUpdates \
  -allowProvisioningDeviceRegistration \
  build -quiet

xcrun devicectl device install app \
  --device "$DEVICE_ID" \
  "$APP_PATH"

echo "TinyKeyboard reinstalled at $(date)"
