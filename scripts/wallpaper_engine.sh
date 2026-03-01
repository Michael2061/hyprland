#!/bin/bash

# Absolute Pfade nutzen
WALLPAPER="$HOME/Pictures/wallpaper/rosie.png"
CACHE_DIR="$HOME/.cache/wal"

# 1. SWWW Daemon Check
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1
fi

# 2. Wallpaper setzen
if [ -f "$WALLPAPER" ]; then
    swww img "$WALLPAPER" --transition-type wipe
    wal -q -i "$WALLPAPER"
else
    echo "❌ Rosie.png nicht gefunden!"
    exit 1
fi

# 3. Hyprland Farben Fix (Wichtig!)
mkdir -p "$CACHE_DIR"
if [ -f "$CACHE_DIR/colors" ]; then
    # Wir nehmen die zweite Zeile von Pywal (dein Pink/Akzent)
    COLOR_VAL=$(sed -n '2p' "$CACHE_DIR/colors" | sed 's/#//')
    echo "\$color1 = rgb($COLOR_VAL)" > "$CACHE_DIR/colors-hyprland.conf"
fi

# 4. UI Reloads
hyprctl reload
killall waybar && waybar &

echo "✅ Rosie-Engine erfolgreich synchronisiert!"
