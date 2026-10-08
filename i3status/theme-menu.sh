#!/usr/bin/env bash
set -eu

BASE="/home/vemund/.config/i3/themes"
CONFIG="/home/vemund/.config/i3/config"
LOG="${XDG_RUNTIME_DIR:-/tmp}/i3-theme-menu.log"
touch "$LOG" 2>/dev/null || LOG="/tmp/i3-theme-menu.log"
export DISPLAY="${DISPLAY:-:0}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/bus}"
exec 2>>"$LOG"

choose_theme() {
  if [ -n "${I3_THEME:-}" ]; then
    printf '%s\n' "$I3_THEME"
    return
  fi
  if command -v zenity >/dev/null 2>&1; then
    zenity --list \
      --title="Theme" \
      --text="Choose color theme" \
      --hide-header \
      --width=260 \
      --height=420 \
      --window-icon=preferences-desktop-theme \
      --column="Theme" \
      "Midnight" \
      "Forest" \
      "Nord" \
      "Solarized" \
      "Rose" \
      "Mint" \
      "Purpys" \
      "Tish" \
      "Eva" \
      "Cyberpunk" \
      "Ice" 2>/dev/null || true
  else
    printf 'Midnight\nForest\nNord\nSolarized\nRose\nMint\nPurpys\nTish\nEva\nCyberpunk\nIce\n' | dmenu -i -p Theme
  fi
}

write_i3_theme() {
  bar="$(cat <<EOF
colors {
background $1
statusline $2
separator $1
focused_workspace $4 $4 $5
active_workspace $7 $7 $2
inactive_workspace $1 $1 $8
urgent_workspace $9 $9 $5
}
EOF
)"

  clients="$(cat <<EOF
client.focused $4 $6 $2 ${11} $4
client.focused_inactive $7 $1 $2 $7 $7
client.unfocused $7 $1 $8 $7 $7
client.urgent $9 ${10} $2 $9 $9
client.placeholder $7 $1 $8 $7 $7
client.background $1
EOF
)"

  BAR="$bar" CLIENTS="$clients" python3 - <<'PY'
import os
from pathlib import Path

path = Path("/home/vemund/.config/i3/config")
text = path.read_text()

def replace_between(src, start, end, body):
    before, rest = src.split(start, 1)
    _, after = rest.split(end, 1)
    return before + start + "\n" + body.rstrip() + "\n" + end + after

text = replace_between(text, "# theme-bar-start", "# theme-bar-end", os.environ["BAR"])
text = replace_between(text, "# theme-clients-start", "# theme-clients-end", os.environ["CLIENTS"])
path.write_text(text)
PY
}

write_status_theme() {
  cat >"$BASE/current.json" <<EOF
{
  "fg": "$1",
  "accent": "$2",
  "warn": "$3",
  "dim": "$4",
  "bg": "$5",
  "section1": "$6",
  "section2": "$7",
  "section3": "$8",
  "section4": "$9",
  "section5": "${10}",
  "section6": "${11}",
  "section7": "${12}"
}
EOF
}

mkdir -p "$BASE"
choice="$(choose_theme)"

case "$choice" in
  Midnight)
    write_i3_theme "#0f111a" "#f8f8f2" "#585b70" "#89b4fa" "#0f111a" "#1e1e2e" "#313244" "#a6adc8" "#f38ba8" "#5b2336" "#f5c177"
    write_status_theme "#cdd6f4" "#89b4fa" "#f38ba8" "#585b70" "#0f111a" "#171a25" "#1b1f2d" "#202535" "#24293b" "#292e42" "#2d3348" "#323850"
    ;;
  Forest)
    write_i3_theme "#101814" "#ecf4ee" "#53665b" "#77b255" "#101814" "#18251e" "#26382e" "#a9b8ad" "#e07a5f" "#4b2c25" "#e9c46a"
    write_status_theme "#d7e6db" "#77b255" "#e07a5f" "#53665b" "#101814" "#142019" "#17261d" "#1b2c22" "#1f3327" "#23392d" "#274033" "#2b4638"
    ;;
  Nord)
    write_i3_theme "#2e3440" "#eceff4" "#4c566a" "#88c0d0" "#2e3440" "#3b4252" "#434c5e" "#d8dee9" "#bf616a" "#4c2f38" "#ebcb8b"
    write_status_theme "#d8dee9" "#88c0d0" "#bf616a" "#4c566a" "#2e3440" "#333a47" "#37404e" "#3b4555" "#404b5c" "#455064" "#4a566b" "#4f5c72"
    ;;
  Solarized)
    write_i3_theme "#002b36" "#eee8d5" "#586e75" "#2aa198" "#002b36" "#073642" "#0f414b" "#93a1a1" "#dc322f" "#4d1f1d" "#b58900"
    write_status_theme "#eee8d5" "#2aa198" "#dc322f" "#586e75" "#002b36" "#06343f" "#0a3a45" "#0f414b" "#144852" "#194f59" "#1e5660" "#235d67"
    ;;
  Rose)
    write_i3_theme "#191724" "#e0def4" "#6e6a86" "#c4a7e7" "#191724" "#1f1d2e" "#26233a" "#908caa" "#eb6f92" "#44263a" "#f6c177"
    write_status_theme "#e0def4" "#c4a7e7" "#eb6f92" "#6e6a86" "#191724" "#1e1b2b" "#231f32" "#28233a" "#2d2841" "#332c49" "#383150" "#3d3658"
    ;;
  Mint)
    write_i3_theme "#09231f" "#e5fff7" "#3f6f65" "#64e6bf" "#09231f" "#10352f" "#17473f" "#9acfc1" "#ff7aa2" "#4a2331" "#c8f58b"
    write_status_theme "#d8fff4" "#64e6bf" "#ff7aa2" "#3f6f65" "#09231f" "#0d2b26" "#11332d" "#153b35" "#19443d" "#1d4c45" "#21554d" "#265e56"
    ;;
  Purpys)
    write_i3_theme "#160f24" "#fff2fb" "#6f5f86" "#ff79c6" "#160f24" "#241735" "#332047" "#d8c3e8" "#8be9fd" "#1f3a4a" "#bd93f9"
    write_status_theme "#f8e9ff" "#ff79c6" "#8be9fd" "#6f5f86" "#160f24" "#20142f" "#2a193a" "#341f46" "#3e2451" "#482a5d" "#532f69" "#5d3574"
    ;;
  Tish)
    write_i3_theme "#21120a" "#fff4df" "#7c5737" "#ff8a1f" "#21120a" "#351b0d" "#4b2610" "#e8c19a" "#ffd166" "#52330d" "#ff4d3d"
    write_status_theme "#ffe9c7" "#ff8a1f" "#ffd166" "#7c5737" "#21120a" "#2c170c" "#371d0e" "#432310" "#4e2912" "#5a3015" "#663617" "#723c19"
    ;;
  Eva)
    write_i3_theme "#050505" "#f4f0e8" "#5b5b5b" "#ff7a00" "#050505" "#111111" "#1d160f" "#b9b1a5" "#39ff14" "#12330d" "#8b5cf6"
    write_status_theme "#f4f0e8" "#ff7a00" "#39ff14" "#5b5b5b" "#050505" "#0d0d0d" "#14110d" "#1d160f" "#261b10" "#302112" "#392614" "#432c16"
    ;;
  Cyberpunk)
    write_i3_theme "#090018" "#f8f8ff" "#5d5078" "#00e5ff" "#090018" "#14002b" "#22103a" "#c8b8ff" "#ff2a6d" "#4a0820" "#f9f871"
    write_status_theme "#f1ecff" "#00e5ff" "#ff2a6d" "#5d5078" "#090018" "#100022" "#18052c" "#210a36" "#290f40" "#32144a" "#3a1954" "#431e5e"
    ;;
  Ice)
    write_i3_theme "#07151f" "#eefaff" "#496979" "#7dd3fc" "#07151f" "#0d2230" "#143041" "#b7d8e8" "#f0abfc" "#472650" "#bae6fd"
    write_status_theme "#e4f7ff" "#7dd3fc" "#f0abfc" "#496979" "#07151f" "#0b1c29" "#0f2433" "#132b3d" "#173347" "#1b3b51" "#20425b" "#244a65"
    ;;
  *)
    exit 0
    ;;
esac

i3-msg reload >/dev/null 2>&1 || true
