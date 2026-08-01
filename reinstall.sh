#!/bin/bash
# Rebuild and reinstall TinyKeyboard to refresh provisioning profile
# Requires: iPhone reachable via USB or same-LAN wireless debugging, and
# trusted; Apple ID signed in to Xcode.
# For remote installs (no USB, no same-LAN, any network) use ota-publish.sh
# instead — see AGENTS.md for the one-time Tailscale setup.
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
