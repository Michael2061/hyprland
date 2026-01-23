#!/bin/bash

# Pfade definieren
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
SWAYOSD_STYLE="$HOME/.config/swayosd/style.css"

# 1. Bild wählen (Fix: Sucht nach jpg, png und jpeg)
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
    echo "❌ Keine Bilder gefunden!"
    exit 1
fi

# 2. Hintergrund & Farben
swww img "$WALLPAPER" --transition-type wipe || { swww-daemon & sleep 1; swww img "$WALLPAPER" --transition-type wipe; }
wal -i "$WALLPAPER"

# 3. Pfade fixen
mkdir -p ~/.config/swayosd
touch "$SWAYOSD_STYLE"
sed -i "s|__HOME__|$HOME|g" "$WAYBAR_STYLE" 2>/dev/null
sed -i "s|__HOME__|$HOME|g" "$SWAYOSD_STYLE" 2>/dev/null

# 4. Waybar & Tastatur-Force
echo "🔄 Starte Waybar und fixe Tastatur..."
killall -9 waybar 2>/dev/null
sleep 2

# DER ENTSCHEIDENDE BEFEHL: Zwingt Hyprland JETZT auf Deutsch
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    hyprctl keyword input:kb_layout de > /dev/null 2>&1
fi

(waybar > /dev/null 2>&1 &)
swayosd-client --reload-style > /dev/null 2>&1

echo "✅ Fertig!"
