#!/bin/bash
# The one wrapper every phone session goes through (make phone-session CMD='...').
#
#   scripts/phone-session.sh <command...>
#
# Takes the phone lock (~/.fm-phone-lock), asks phone-reach for the device and
# runs the command with DEVICE_ID exported and PHONE_SESSION=1. phone-reach
# brings up the Tailscale road to the phone (and uses the LAN by itself when the
# phone happens to share it); nothing here needs the phone on any particular
# network, and nothing asks anyone to open a link or tap Install. The lock is
# released on exit, INT and TERM; the exit status is the command's.
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=phone-lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/phone-lib.sh"

[ $# -gt 0 ] || { echo "usage: phone-session.sh <command...>   (or: make phone-session CMD='...')" >&2; exit 2; }

phone_lock_take "$@"
trap phone_lock_release EXIT
trap 'exit 143' TERM
trap 'exit 130' INT

DEVICE_ID="$(phone-reach --wait 120)" || exit 1
export DEVICE_ID PHONE_SESSION=1

"$@" </dev/null
