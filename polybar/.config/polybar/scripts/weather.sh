#!/usr/bin/env bash
# =============================================================================
# Instant Cached Weather Provider (wttr.in + Zero-Block Background Refresh)
# =============================================================================

CACHE_FILE="/tmp/torray_weather_cache"
TTL=900  # 15 minutes

fetch_weather() {
    raw=$(curl -s --max-time 4 "https://wttr.in/?format=%l|%c|%t|%C|%h|%w" 2>/dev/null || echo "")
    if [ -n "$raw" ] && [[ "$raw" == *"|"* ]] && [[ "$raw" != *"Unknown"* ]]; then
        printf '%s\n' "$raw" > "$CACHE_FILE"
    fi
}

if [ "${1:-}" = "--refresh" ]; then
    fetch_weather
    exit 0
fi

if [ ! -s "$CACHE_FILE" ]; then
    fetch_weather
else
    now=$(printf '%(%s)T' -1)
    mtime=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
    if [ $((now - mtime)) -gt "$TTL" ]; then
        setsid -f "$0" --refresh >/dev/null 2>&1 < /dev/null
    fi
fi

if [ -s "$CACHE_FILE" ]; then
    IFS='|' read -r loc icon temp cond hum wind < "$CACHE_FILE"
    city="${loc%%,*}"
    temp="${temp#+}"
    icon="${icon// /}"
    if [ "${1:-}" = "--json" ]; then
        printf '{"city":"%s","icon":"%s","temp":"%s","cond":"%s","hum":"%s","wind":"%s"}\n' \
            "$city" "$icon" "$temp" "$cond" "$hum" "$wind"
    else
        printf '%s %s • %s (%s) • 󰖎 %s 󰖝 %s\n' "$icon" "$temp" "$cond" "$city" "$hum" "$wind"
    fi
else
    printf '󰖐 Weather Unavailable\n'
fi
