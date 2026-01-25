#!/bin/bash

# Pfade
WAYBAR_CONFIG="$HOME/.config/waybar/config"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
WALLPAPER="$HOME/Pictures/Wallpapers/rosie.png"

echo "🎨 Rosie-Engine wird gestartet..."

# 1. Prüfen, ob das Bild da ist
if [ -f "$WALLPAPER" ]; then
    # Farben generieren (Pywal)
    wal -q -i "$WALLPAPER"
    # Wallpaper setzen (swww)
    swww img "$WALLPAPER" --transition-step 20 --transition-fps 60 --transition-type wipe
else
    echo "⚠️ rosie.png nicht gefunden, suche Alternativen..."
    WALLPAPER=$(find "$HOME/Pictures/Wallpapers" -type f \( -name "*.png" -o -name "*.jpg" \) | shuf -n 1)
    [ -n "$WALLPAPER" ] && wal -q -i "$WALLPAPER" && swww img "$WALLPAPER"
fi

# 2. Synchronisation für Login & Lockscreen (Cache)
# Das complete_setup.sh hat SDDM bereits gesagt, dass es hier schauen soll
cp "$WALLPAPER" "$HOME/.cache/current_wallpaper.png"
cp "$WALLPAPER" "$HOME/.cache/rosie_avatar.png"

# 3. CSS-Verbindung (Pywal Farben in Waybar laden)
if [ -f "$WAYBAR_STYLE" ]; then
    # Sicherstellen, dass der Import-Befehl für Pywal-Farben ganz oben steht
    if ! grep -q "colors-waybar.css" "$WAYBAR_STYLE"; then
        echo "@import url(\"file://$HOME/.cache/wal/colors-waybar.css\");" | cat - "$WAYBAR_STYLE" > temp && mv temp "$WAYBAR_STYLE"
    fi
    # User-Platzhalter ersetzen
    sed -i "s|__USER__|$USER|g" "$WAYBAR_STYLE"
fi

# 4. Waybar Neustart
killall waybar 2>/dev/null
sleep 0.5
waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &

echo "✅ Rosie-Design (PNG) und Pywal-Farben aktiv!"