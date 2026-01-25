#!/bin/bash

# 1. Pfade definieren
WAYBAR_CONFIG="$HOME/.config/waybar/config"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
WALLPAPER="$HOME/Pictures/Wallpapers/rosie.png"

# 2. Prüfen, ob Rosie-Wallpaper existiert
if [ -f "$WALLPAPER" ]; then
    echo "🌹 Rosie-Design wird geladen..."
    # Pywal generiert hier die ~/.cache/wal/colors-waybar.css
    wal -q -i "$WALLPAPER"
    # Wallpaper setzen
    swww img "$WALLPAPER" --transition-step 20 --transition-fps 60 --transition-type wipe
else
    echo "⚠️ Rosie.png fehlt, lade Zufallsbild..."
    WALLPAPER=$(find "$HOME/Pictures/Wallpapers" -type f \( -name "*.png" -o -name "*.jpg" \) | shuf -n 1)
    [ -n "$WALLPAPER" ] && wal -q -i "$WALLPAPER" && swww img "$WALLPAPER"
fi

# 3. Synchronisation für SDDM & Hyprlock (Cache-Dateien)
cp "$WALLPAPER" "$HOME/.cache/current_wallpaper.png"
cp "$WALLPAPER" "$HOME/.cache/rosie_avatar.png"

# 4. CSS-REPARATUR & IMPORT-CHECK
# Wir stellen sicher, dass die style.css die Pywal-Farben IMPORTIERT
if [ -f "$WAYBAR_STYLE" ]; then
    # Prüfen, ob der Import schon drin steht, wenn nicht -> oben einfügen
    if ! grep -q "@import url(\"file://$HOME/.cache/wal/colors-waybar.css\");" "$WAYBAR_STYLE"; then
        echo "🔗 Füge Pywal-Import zu style.css hinzu..."
        echo "@import url(\"file://$HOME/.cache/wal/colors-waybar.css\");" | cat - "$WAYBAR_STYLE" > temp && mv temp "$WAYBAR_STYLE"
    fi
    
    # Ersetze Platzhalter __USER__ durch den echten Namen
    sed -i "s|__USER__|$USER|g" "$WAYBAR_STYLE"
fi

# 5. Waybar Neustart
killall waybar 2>/dev/null
sleep 0.5
waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &

echo "✅ Wallpaper & Farben (Pywal) erfolgreich synchronisiert!"