#!/usr/bin/env bash

set -eu

source_image="$HOME/.config/sway/wallpaper.png"
lock_image="${XDG_RUNTIME_DIR:-/tmp}/torray-lockscreen.png"

magick "$source_image" -resize 1366x768^ -gravity center -extent 1366x768 "$lock_image"
exec i3lock -n -i "$lock_image" -e -f
