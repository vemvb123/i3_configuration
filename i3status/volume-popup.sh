#!/usr/bin/env bash
set -eu
LOG="${XDG_RUNTIME_DIR:-/tmp}/i3-volume-popup.log"
export DISPLAY="${DISPLAY:-:0}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/bus}"
exec 2>>"$LOG"

get_volume() {
  if command -v wpctl >/dev/null 2>&1; then
    wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '/Volume:/ { printf "%.0f\n", $2 * 100; found=1 } END { if (!found) print 50 }'
  else
    amixer get Master 2>/dev/null | awk -F'[][]' '/%/ { gsub("%", "", $2); print $2; exit } END { if (NR == 0) print 50 }'
  fi
}

set_volume() {
  value="$1"
  if command -v wpctl >/dev/null 2>&1; then
    wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 >/dev/null 2>&1 || true
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "${value}%" >/dev/null 2>&1 || true
  else
    amixer -q set Master "${value}%" unmute >/dev/null 2>&1 || true
  fi
}

current="$(get_volume)"

if ! command -v zenity >/dev/null 2>&1; then
  i3-nagbar -t warning -m "Zenity is not installed, cannot open volume slider" >/dev/null 2>&1 || true
  exit 0
fi

zenity --scale \
  --title="Volume" \
  --text="Adjust volume" \
  --min-value=0 \
  --max-value=100 \
  --value="$current" \
  --step=1 \
  --width=320 \
  --height=90 \
  --window-icon=audio-volume-high \
  --print-partial 2>/dev/null | while read -r value; do
    case "$value" in
      ''|*[!0-9]*) ;;
      *) set_volume "$value" ;;
    esac
  done
