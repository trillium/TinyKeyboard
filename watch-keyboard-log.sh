#!/bin/bash
# Stream ONLY TinyKeyboard-related lines from the connected iPhone's syslog.
# Requires: libimobiledevice (idevicesyslog), iPhone connected + unlocked.
set -e
DEVICE_ID="00008150-000509C03442401C"
echo "Streaming TinyKeyboard logs from $DEVICE_ID — Ctrl-C to stop."
echo "Switch to TinyKeyboard on the phone to see viewDidLoad / viewDidAppear / height."
idevicesyslog -u "$DEVICE_ID" \
  | grep -iE "TinyKeyboard|com\.trillium|keyboard.*height|UIInputView" --line-buffered
