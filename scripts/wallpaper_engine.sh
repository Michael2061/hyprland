#!/bin/bash

WALLPAPER="$HOME/Pictures/wallpaper/rosie.png"
CACHE_DIR="$HOME/.cache/wal"

# 1. SWWW Daemon Check
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1
fi

# 2. Wallpaper & Pywal
if [ -f "$WALLPAPER" ]; then
    swww img "$WALLPAPER" --transition-type wipe
    wal -q -i "$WALLPAPER"
else
    echo "❌ Rosie.png nicht gefunden!"
    exit 1
fi

# 3. Hyprland Border-Farben Fix
# Wir erstellen eine Datei, die Hyprland direkt als 'source' einliest
mkdir -p "$CACHE_DIR"
{
  echo "\$color1 = $(sed -n '2p' $CACHE_DIR/colors)"
  echo "\$color2 = $(sed -n '3p' $CACHE_DIR/colors)"
} > "$CACHE_DIR/colors-hyprland.conf"

# 4. UI Reloads
# Wir sagen Hyprland Bescheid und starten Waybar neu
hyprctl reload
killall waybar
waybar &

# Rofi braucht keinen Reload, es liest die Datei beim Starten