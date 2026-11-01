#!/bin/bash
# Shared by the phone scripts (sourced, never run). The phone lock is the
# directory ~/.fm-phone-lock (PHONE_LOCK) holding pid, started and command.
# Every script that talks to the phone takes it, then runs `phone-reach` for
# the device id: see phone-session.sh. phone-reach reaches the phone over
# Tailscale by default and falls back to a shared LAN on its own.

PHONE_LOCK="${PHONE_LOCK:-$HOME/.fm-phone-lock}"

phone_say() { echo "phone: $*" >&2; }
phone_die() { phone_say "error: $*"; exit 1; }

# phone_lock_take COMMAND...: mkdir the lock; a lock whose holder is gone is reclaimed.
phone_lock_take() {
  local tries=0 pid
  while ! mkdir "$PHONE_LOCK" 2>/dev/null; do
    tries=$((tries + 1))
    [ "$tries" -le 3 ] || phone_die "cannot take the phone lock $PHONE_LOCK"
    pid="$(cat "$PHONE_LOCK/pid" 2>/dev/null || true)"
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      phone_die "phone lock $PHONE_LOCK is held by pid $pid running '$(cat "$PHONE_LOCK/command" 2>/dev/null || echo '?')'; refusing"
    fi
    phone_say "reclaiming stale lock $PHONE_LOCK (holder ${pid:-unknown} is gone)"
    # rename first: of two racing reclaimers only one rename succeeds
    if mv "$PHONE_LOCK" "$PHONE_LOCK.stale.$$" 2>/dev/null; then rm -rf "$PHONE_LOCK.stale.$$"; fi
  done
  printf '%s\n' "$$" >"$PHONE_LOCK/pid"
  date +%s >"$PHONE_LOCK/started"
  printf '%s\n' "$*" >"$PHONE_LOCK/command"
}

phone_lock_release() { rm -rf "$PHONE_LOCK"; }

# phone_in_session: the caller already holds the lock and has a DEVICE_ID.
phone_in_session() { [ "${PHONE_SESSION:-}" = 1 ] && [ -n "${DEVICE_ID:-}" ]; }
