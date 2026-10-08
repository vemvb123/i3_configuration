#!/usr/bin/env python3
import json
import os
import re
import select
import signal
import subprocess
import sys
import time
from datetime import datetime

NET_ROOT = "/sys/class/net"
IGNORE_NET = {"lo", "docker0"}
INTERVAL = 1.0
THEME_PATH = "/home/vemund/.config/i3/themes/current.json"
FG = "#cdd6f4"
ACCENT = "#89b4fa"
WARN = "#f38ba8"
DIM = "#585b70"
BG = "#0f111a"
SECTION1 = "#171a25"
SECTION2 = "#1b1f2d"
SECTION3 = "#202535"
SECTION4 = "#24293b"
SECTION5 = "#292e42"
SECTION6 = "#2d3348"
SECTION7 = "#323850"


def icon(char):
    return f"<span font_desc='FontAwesome'>{char}</span>"


def sh(cmd):
    try:
        return subprocess.check_output(cmd, stderr=subprocess.DEVNULL, text=True).strip()
    except Exception:
        return ""


def run(cmd):
    subprocess.Popen(
        cmd,
        shell=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        env={**os.environ, "DISPLAY": os.environ.get("DISPLAY", ":0")},
    )


def read(path, default=""):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return f.read().strip()
    except Exception:
        return default


def theme():
    fallback = {
        "fg": FG,
        "accent": ACCENT,
        "warn": WARN,
        "dim": DIM,
        "bg": BG,
        "section1": SECTION1,
        "section2": SECTION2,
        "section3": SECTION3,
        "section4": SECTION4,
        "section5": SECTION5,
        "section6": SECTION6,
        "section7": SECTION7,
    }
    try:
        with open(THEME_PATH, "r", encoding="utf-8") as f:
            data = json.load(f)
        return {**fallback, **{k: v for k, v in data.items() if isinstance(v, str)}}
    except Exception:
        return fallback


def iface_kind(iface):
    if os.path.isdir(os.path.join(NET_ROOT, iface, "wireless")) or iface.startswith(("wl", "wlan")):
        return "wifi"
    if iface.startswith(("en", "eth")):
        return "wired"
    return "net"


def active_iface():
    candidates = []
    for iface in sorted(os.listdir(NET_ROOT)):
        if iface in IGNORE_NET:
            continue
        state = read(os.path.join(NET_ROOT, iface, "operstate"), "down")
        if state in {"up", "unknown"}:
            rx = int(read(os.path.join(NET_ROOT, iface, "statistics/rx_bytes"), "0") or 0)
            tx = int(read(os.path.join(NET_ROOT, iface, "statistics/tx_bytes"), "0") or 0)
            score = 2 if state == "up" else 1
            if iface.startswith("tailscale"):
                score -= 1
            candidates.append((score, rx + tx, iface))
    return sorted(candidates, reverse=True)[0][2] if candidates else ""


def human_rate(num):
    units = ["B/s", "KB/s", "MB/s", "GB/s"]
    value = float(max(num, 0))
    for unit in units:
        if value < 1024 or unit == units[-1]:
            return f"{value:.0f} {unit}" if unit == "B/s" else f"{value:.1f} {unit}"
        value /= 1024


def volume_meter(volume, muted):
    if muted:
        return "────○"
    if volume is None:
        return "────○"
    slots = 6
    pos = min(slots - 1, max(0, round(volume / 100 * (slots - 1))))
    return "━" * pos + "●" + "─" * (slots - 1 - pos)


def get_volume():
    wp = sh(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"])
    if wp:
        muted = "[MUTED]" in wp
        match = re.search(r"Volume:\s+([0-9.]+)", wp)
        volume = round(float(match.group(1)) * 100) if match else None
        return volume, muted
    out = sh(["amixer", "get", "Master"])
    muted = "[off]" in out
    match = re.findall(r"\[(\d+)%\]", out)
    volume = int(match[-1]) if match else None
    return volume, muted


def net_block(prev, colors):
    iface = active_iface()
    if not iface:
        return {"name": "network", "markup": "pango", "full_text": f"  {icon('')} Offline  ", "min_width": "    ↓ 999.9 MB/s  ↑ 999.9 MB/s  ", "align": "center", "color": colors["warn"], "background": colors["section2"]}
    rx = int(read(os.path.join(NET_ROOT, iface, "statistics/rx_bytes"), "0") or 0)
    tx = int(read(os.path.join(NET_ROOT, iface, "statistics/tx_bytes"), "0") or 0)
    now = time.time()
    old_t, old_rx, old_tx = prev.get(iface, (now, rx, tx))
    elapsed = max(now - old_t, 0.001)
    prev[iface] = (now, rx, tx)
    kind = iface_kind(iface)
    net_icon = "" if kind == "wifi" else "" if kind == "wired" else ""
    return {
        "name": "network",
        "markup": "pango",
        "full_text": f"  {icon(net_icon)}  ↓ {human_rate((rx - old_rx) / elapsed)}  ↑ {human_rate((tx - old_tx) / elapsed)}  ",
        "min_width": "    ↓ 999.9 MB/s  ↑ 999.9 MB/s  ",
        "align": "center",
        "color": colors["fg"],
        "background": colors["section2"],
    }


def volume_block(colors):
    volume, muted = get_volume()
    text = "Muted" if muted else f"{volume}%" if volume is not None else "n/a"
    return {"name": "volume", "markup": "pango", "full_text": f"  {icon('' if muted else '')} {text}  ", "min_width": "   100%  ", "align": "center", "color": colors["accent"], "background": colors["section3"]}


def temp_block(colors):
    temps = []
    for name in os.listdir("/sys/class/thermal") if os.path.isdir("/sys/class/thermal") else []:
        raw = read(f"/sys/class/thermal/{name}/temp")
        if raw.isdigit():
            temps.append(int(raw) / 1000)
    text = f"{max(temps):.0f} C" if temps else "n/a"
    return {"name": "temp", "markup": "pango", "full_text": f"  {icon('')} {text}  ", "color": colors["fg"], "background": colors["section4"]}


def load_block(colors):
    load = os.getloadavg()[0]
    return {"name": "load", "markup": "pango", "full_text": f"  {icon('')} {load:.2f}  ", "color": colors["fg"], "background": colors["section5"]}


def date_block(colors):
    return {"name": "date", "markup": "pango", "full_text": f"  {icon('')} " + datetime.now().strftime("%a %d %b  %H:%M") + "  ", "color": colors["fg"], "background": colors["section6"]}


def theme_block(colors):
    return {"name": "theme", "markup": "pango", "full_text": f"  {icon('')}  ", "min_width": "    ", "align": "center", "color": colors["accent"], "background": colors["section1"]}


def power_block(colors):
    return {"name": "power", "markup": "pango", "full_text": f"  {icon('')}  ", "min_width": "    ", "align": "center", "color": colors["warn"], "background": colors["section7"]}


def output(prev, first):
    colors = theme()
    blocks = [theme_block(colors), net_block(prev, colors), volume_block(colors), temp_block(colors), load_block(colors), date_block(colors), power_block(colors)]
    for block in blocks:
        block["separator"] = False
        block["separator_block_width"] = 0
    prefix = "" if first else ","
    print(prefix + json.dumps(blocks), flush=True)


def handle_click(line):
    try:
        event = json.loads(line.lstrip(","))
    except Exception:
        return
    name = event.get("name")
    button = event.get("button")
    if name == "volume":
        if button == 1:
            run("/home/vemund/.config/i3status/volume-popup.sh")
        elif button == 3:
            run("command -v wpctl >/dev/null && wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle || amixer -q set Master toggle")
        elif button == 4:
            run("command -v wpctl >/dev/null && wpctl set-volume -l 1.2 @DEFAULT_AUDIO_SINK@ 5%+ || amixer -q set Master 5%+")
        elif button == 5:
            run("command -v wpctl >/dev/null && wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- || amixer -q set Master 5%-")
    elif name == "network" and button == 1:
        run("kitty -e nmcli device status")
    elif name == "theme" and button == 1:
        run("/home/vemund/.config/i3status/theme-menu.sh")
    elif name == "power" and button == 1:
        run("/home/vemund/.config/i3status/power-menu.sh")


def main():
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    print('{"version":1,"click_events":true}', flush=True)
    print("[", flush=True)
    prev = {}
    first = True
    while True:
        output(prev, first)
        first = False
        deadline = time.time() + INTERVAL
        while time.time() < deadline:
            remaining = max(deadline - time.time(), 0)
            readable, _, _ = select.select([sys.stdin], [], [], min(remaining, 0.2))
            if readable:
                line = sys.stdin.readline()
                if line:
                    handle_click(line)


if __name__ == "__main__":
    main()
