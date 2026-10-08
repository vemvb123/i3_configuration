#!/usr/bin/env bash
set -eu
LOG="${XDG_RUNTIME_DIR:-/tmp}/i3-power-menu.log"
export DISPLAY="${DISPLAY:-:0}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/bus}"
exec 2>>"$LOG"

if ! command -v zenity >/dev/null 2>&1; then
  i3-nagbar -t warning -m "Power menu" -b "Logout" "i3-msg exit" -b "Reboot" "systemctl reboot" -b "Power off" "systemctl poweroff"
  exit 0
fi

choice="$(
  zenity --list \
    --title="Power" \
    --text="Choose an action" \
    --hide-header \
    --width=260 \
    --height=190 \
    --window-icon=system-shutdown \
    --column="Action" \
    "Logout" \
    "Reboot" \
    "Power off" 2>/dev/null || true
)"

case "$choice" in
  Logout)
    zenity --question --title="Logout" --text="Log out to the login screen?" --width=280 --window-icon=system-log-out 2>/dev/null && i3-msg exit
    ;;
  Reboot)
    zenity --question --title="Reboot" --text="Reboot this PC?" --width=280 --window-icon=system-reboot 2>/dev/null && systemctl reboot
    ;;
  "Power off")
    zenity --question --title="Power off" --text="Power off this PC?" --width=280 --window-icon=system-shutdown 2>/dev/null && systemctl poweroff
    ;;
esac
