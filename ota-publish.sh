#!/bin/bash
# Build an ad-hoc-signed .ipa and publish it as an OTA (itms-services) install
# package: manifest.plist + index.html + the .ipa, dropped into a served
# folder (default ~/ota). This is the ONLY way to install on the captain's
# iPhone: serve the folder tailnet-only with `tailscale serve --https=8784`
# (never Funnel, never the :443 root or :8443) and tap Install in Safari with
# Tailscale connected — see AGENTS.md ("OTA install over Tailscale").
#
# Requires: paid Apple Developer Program team TV2582LRYN already configured
# in TinyKeyboard.xcodeproj (ad-hoc profiles valid ~1yr, not 7 days), `jq`, and
# the `tailscale` CLI logged in on this Mac (only when OTA_BASE_URL is unset —
# it's what the default base URL is derived from). Run scripts/run-tests.sh
# first; never publish a build that fails it.
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEME="TinyKeyboard"
BUNDLE_ID="com.trillium.TinyKeyboard"
TITLE="TinyKeyboard"
OTA_DIR="${OTA_DIR:-$HOME/ota}"

cd "$PROJECT_DIR"

REQUIRED_TOOLS="jq xcodebuild"
# Only the derived-hostname path needs the tailscale CLI; an explicit
# OTA_BASE_URL (alternate port, subpath mount, non-tailnet host) doesn't.
[ -n "${OTA_BASE_URL:-}" ] || REQUIRED_TOOLS="tailscale $REQUIRED_TOOLS"
for tool in $REQUIRED_TOOLS; do
  command -v "$tool" >/dev/null 2>&1 || { echo "error: required tool not found on PATH: $tool" >&2; exit 1; }
done

mkdir -p "$OTA_DIR"

# Build artifacts (the .xcarchive, export dir, dSYMs, and the ad-hoc
# embedded.mobileprovision) must never land inside OTA_DIR: that whole
# folder is served over the tailnet, and http.server's directory listing
# doesn't hide dotfiles.
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/tinykeyboard-ota-build.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT
ARCHIVE_PATH="$BUILD_DIR/TinyKeyboard.xcarchive"
EXPORT_PATH="$BUILD_DIR/export"

# Where the published files will be reachable from the iPhone: this Mac's
# tailnet name (derived, never hardcoded) on TinyKeyboard's port 8784. Override
# OTA_BASE_URL only if the folder is served at a different https:// address.
if [ -n "${OTA_BASE_URL:-}" ]; then
  # Strip trailing slashes so composed URLs never contain '//'.
  while [ "${OTA_BASE_URL%/}" != "$OTA_BASE_URL" ]; do OTA_BASE_URL="${OTA_BASE_URL%/}"; done
  case "$OTA_BASE_URL" in
    https://*) ;;
    *)
      echo "error: OTA_BASE_URL must start with 'https://' (got: $OTA_BASE_URL)" >&2
      echo "       iOS refuses itms-services manifests over plain HTTP, so the install would fail silently on the phone." >&2
      exit 1
      ;;
  esac
else
  # Derive this Mac's tailnet hostname instead of hardcoding a machine name.
  HOST="$(tailscale status --json | jq -r '.Self.DNSName | rtrimstr(".")')"
  if [ -z "$HOST" ] || [ "$HOST" = "null" ]; then
    echo "error: could not determine tailnet hostname from 'tailscale status --json' (.Self.DNSName)" >&2
    echo "       is tailscale running and logged in, and is MagicDNS enabled for this tailnet?" >&2
    exit 1
  fi
  OTA_BASE_URL="https://$HOST:8784"
fi

# Bump the build number so iOS's OTA installer doesn't silently no-op when
# reinstalling what looks like the same version.
BUNDLE_VERSION="$(date -u +%Y%m%d%H%M%S)"

echo "Archiving $SCHEME (build $BUNDLE_VERSION)..."
rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"
xcodebuild -project TinyKeyboard.xcodeproj \
  -scheme "$SCHEME" \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  -allowProvisioningDeviceRegistration \
  CURRENT_PROJECT_VERSION="$BUNDLE_VERSION" \
  archive -quiet

echo "Exporting ad-hoc .ipa..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$PROJECT_DIR/exportOptions.plist" \
  -allowProvisioningUpdates -quiet

IPA_SRC="$EXPORT_PATH/$SCHEME.ipa"
if [ ! -f "$IPA_SRC" ]; then
  echo "error: expected ipa not found at $IPA_SRC" >&2
  exit 1
fi

IPA_NAME="TinyKeyboard.ipa"
cp -f "$IPA_SRC" "$OTA_DIR/$IPA_NAME"

IPA_URL="$OTA_BASE_URL/$IPA_NAME"
MANIFEST_URL="$OTA_BASE_URL/manifest.plist"
ENCODED_MANIFEST_URL="$(printf '%s' "$MANIFEST_URL" | jq -sRr @uri)"
INSTALL_URL="itms-services://?action=download-manifest&url=$ENCODED_MANIFEST_URL"

# Escape sed replacement metacharacters (& and \) so the itms-services URL's
# '&' isn't read as "insert the matched pattern" by sed.
sed_escape() { printf '%s' "$1" | sed -e 's/[&\]/\\&/g'; }

sed -e "s#__IPA_URL__#$(sed_escape "$IPA_URL")#g" \
    -e "s#__BUNDLE_ID__#$(sed_escape "$BUNDLE_ID")#g" \
    -e "s#__BUNDLE_VERSION__#$(sed_escape "$BUNDLE_VERSION")#g" \
    -e "s#__TITLE__#$(sed_escape "$TITLE")#g" \
    "$PROJECT_DIR/ota/manifest.plist.template" > "$OTA_DIR/manifest.plist"

sed -e "s#__INSTALL_URL__#$(sed_escape "$INSTALL_URL")#g" \
    -e "s#__BUNDLE_VERSION__#$(sed_escape "$BUNDLE_VERSION")#g" \
    -e "s#__TITLE__#$(sed_escape "$TITLE")#g" \
    "$PROJECT_DIR/ota/index.html.template" > "$OTA_DIR/index.html"

echo ""
echo "Published build $BUNDLE_VERSION to $OTA_DIR"
echo "  Install page: $OTA_BASE_URL/"
echo ""
echo "If it isn't serving yet (tailnet only; never Funnel, never :443 root or :8443):"
echo "  (cd $OTA_DIR && python3 -m http.server 8794 --bind 127.0.0.1) &"
echo "  tailscale serve --bg --https=8784 http://127.0.0.1:8794"
echo "Then open the install page in Safari on the iPhone with Tailscale connected and tap Install."
