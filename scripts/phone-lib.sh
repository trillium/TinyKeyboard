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
# A lock with no pid yet belongs to a holder that has only just made it: wait, never reclaim.
phone_lock_take() {
  local tries=0 pid stale
  while ! mkdir "$PHONE_LOCK" 2>/dev/null; do
    tries=$((tries + 1))
    [ "$tries" -le 3 ] || phone_die "cannot take the phone lock $PHONE_LOCK"
    pid="$(cat "$PHONE_LOCK/pid" 2>/dev/null || true)"
    if [ -z "$pid" ]; then sleep 1; continue; fi
    if kill -0 "$pid" 2>/dev/null; then
      phone_die "phone lock $PHONE_LOCK is held by pid $pid running '$(cat "$PHONE_LOCK/command" 2>/dev/null || echo '?')'; refusing"
    fi
    phone_say "reclaiming stale lock $PHONE_LOCK (holder $pid is gone)"
    # rename first, then delete only if what was renamed is still the dead holder's lock
    stale="$PHONE_LOCK.stale.$$"
    if mv "$PHONE_LOCK" "$stale" 2>/dev/null; then
      if [ "$(cat "$stale/pid" 2>/dev/null || true)" != "$pid" ]; then
        [ -e "$PHONE_LOCK" ] || mv "$stale" "$PHONE_LOCK"
        phone_die "phone lock $PHONE_LOCK was retaken while reclaiming it; refusing"
      fi
      rm -rf "$stale"
    fi
  done
  printf '%s\n' "$$" >"$PHONE_LOCK/pid"
  date +%s >"$PHONE_LOCK/started"
  printf '%s\n' "$*" >"$PHONE_LOCK/command"
}

# phone_lock_release: remove the lock only while it is still ours.
phone_lock_release() {
  [ "$(cat "$PHONE_LOCK/pid" 2>/dev/null || true)" = "$$" ] && rm -rf "$PHONE_LOCK"
  return 0
}

# phone_in_session: the caller already holds the lock and has a DEVICE_ID.
phone_in_session() { [ "${PHONE_SESSION:-}" = 1 ] && [ -n "${DEVICE_ID:-}" ]; }
