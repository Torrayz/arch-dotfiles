#!/usr/bin/env bash
# =============================================================================
# Interactive Expandable System Pill (Zero-Fork Pure Bash Builtins)
# Reads /proc/stat, /proc/meminfo, and /sys/class/thermal directly without
# spawning sleep, free, awk, sed, or cat!
# =============================================================================

STATE_FILE="/tmp/bar_sysinfo_expanded"
CPU_CACHE="/tmp/bar_cpu_prev"

if [ "${1:-}" = "--toggle" ]; then
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
    else
        rm -f /tmp/bar_clock_expanded /tmp/bar_net_expanded /tmp/bar_power_expanded
        : > "$STATE_FILE"
    fi
    pkill -RTMIN+8 waybar 2>/dev/null || true
    exit 0
fi

read -r _ u n s idle iow irq sirq _ < /proc/stat
total=$((u + n + s + idle + iow + irq + sirq))

prev_total=0
prev_idle=0
if [ -r "$CPU_CACHE" ]; then
    read -r prev_total prev_idle < "$CPU_CACHE"
fi
printf '%s %s\n' "$total" "$idle" > "$CPU_CACHE"

diff_total=$((total - prev_total))
diff_idle=$((idle - prev_idle))
if [ "$diff_total" -gt 0 ] && [ "$prev_total" -gt 0 ]; then
    cpu_usage=$(( (100 * (diff_total - diff_idle)) / diff_total ))
else
    cpu_usage=0
fi

if [ -f "$STATE_FILE" ]; then
    mem_total=0
    mem_avail=0
    while IFS=': ' read -r key val _; do
        case "$key" in
            MemTotal) mem_total=$val ;;
            MemAvailable) mem_avail=$val; break ;;
        esac
    done < /proc/meminfo
    used_mb=$(( (mem_total - mem_avail) / 1024 ))
    if [ "$used_mb" -ge 1024 ]; then
        gb_int=$(( used_mb / 1024 ))
        gb_dec=$(( (used_mb % 1024) * 10 / 1024 ))
        mem_str="${gb_int}.${gb_dec}G"
    else
        mem_str="${used_mb}M"
    fi

    temp="N/A"
    for tz in /sys/class/thermal/thermal_zone*/temp; do
        if [ -r "$tz" ]; then
            read -r raw < "$tz"
            temp="$((raw / 1000))°C"
            break
        fi
    done
    printf '󰻠  %s%%  •  󰍛  %s  •  󰔏  %s  󰅁\n' "$cpu_usage" "$mem_str" "$temp"
else
    printf '󰻠  %s%%  󰅂\n' "$cpu_usage"
fi
