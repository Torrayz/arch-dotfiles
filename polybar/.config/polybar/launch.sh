#!/usr/bin/env bash
# =============================================================================
# Bulletproof Polybar Launcher with Detached Watchdog (Immune to SIGPIPE/SIGHUP)
# =============================================================================

pkill -f "polybar_watchdog_loop" 2>/dev/null || true
killall -q polybar 2>/dev/null || true
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.1; done

setsid -f bash -c '
    # polybar_watchdog_loop
    while true; do
        polybar main >/tmp/polybar.log 2>&1
        sleep 0.5
    done
' >/dev/null 2>&1 < /dev/null
