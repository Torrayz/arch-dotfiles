#!/usr/bin/env bash
# =============================================================================
# Bulletproof Single-Instance Polybar Watchdog Launcher
# - Uses polybar-msg cmd restart if already running (zero flicker, zero duplicates)
# - Automatically revives Polybar if it ever exits unexpectedly
# =============================================================================

WD_PID_FILE="/tmp/polybar_watchdog.pid"

if pgrep -u "$UID" -x polybar >/dev/null 2>&1 && [ -f "$WD_PID_FILE" ]; then
    wd_pid=$(cat "$WD_PID_FILE" 2>/dev/null || echo "")
    if [ -n "$wd_pid" ] && kill -0 "$wd_pid" 2>/dev/null; then
        polybar-msg cmd restart >/dev/null 2>&1 && exit 0
    fi
fi

# Clean up any old watchdog or polybar instance before starting fresh
if [ -f "$WD_PID_FILE" ]; then
    old_wd=$(cat "$WD_PID_FILE" 2>/dev/null || echo "")
    [ -n "$old_wd" ] && kill "$old_wd" 2>/dev/null || true
    rm -f "$WD_PID_FILE"
fi
killall -q polybar 2>/dev/null || true
while pgrep -u "$UID" -x polybar >/dev/null 2>&1; do sleep 0.1; done

setsid -f bash -c '
    echo $$ > /tmp/polybar_watchdog.pid
    while true; do
        polybar main >/tmp/polybar.log 2>&1
        sleep 0.4
    done
' >/dev/null 2>&1 < /dev/null
