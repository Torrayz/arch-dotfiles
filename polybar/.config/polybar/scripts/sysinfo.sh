#!/usr/bin/env bash
# =============================================================================
# Interactive Expandable System Pill (Mutual-Exclusion Accordion)
# =============================================================================

STATE_FILE="/tmp/bar_sysinfo_expanded"

if [ "${1:-}" = "--toggle" ]; then
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
    else
        rm -f /tmp/bar_clock_expanded /tmp/bar_net_expanded /tmp/bar_power_expanded
        touch "$STATE_FILE"
    fi
    pkill -RTMIN+8 waybar 2>/dev/null || true
    exit 0
fi

read -r _ a b c previdle _ < /proc/stat
prevtotal=$((a+b+c+previdle))
sleep 0.12
read -r _ a b c idle _ < /proc/stat
total=$((a+b+c+idle))
diff_idle=$((idle - previdle))
diff_total=$((total - prevtotal))
if [ "$diff_total" -gt 0 ]; then
    cpu_usage=$(( (100 * (diff_total - diff_idle)) / diff_total ))
else
    cpu_usage=0
fi

if [ -f "$STATE_FILE" ]; then
    mem_used=$(free -h | awk '/^Mem:/ {print $3}' | sed 's/i//g')
    temp="N/A"
    for tz in /sys/class/thermal/thermal_zone*/temp; do
        if [ -r "$tz" ]; then
            raw=$(cat "$tz")
            temp="$((raw / 1000))°C"
            break
        fi
    done
    echo "󰻠  ${cpu_usage}%  •  󰍛  ${mem_used}  •  󰔏  ${temp}  󰅁"
else
    echo "󰻠  ${cpu_usage}%  󰅂"
fi
