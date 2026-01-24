 #!/bin/bash


# Pfade

WAYBAR_CONFIG="$HOME/.config/waybar/config"

WAYBAR_STYLE="$HOME/.config/waybar/style.css"

WALLPAPER="$HOME/Pictures/Wallpapers/rosie.jpg"


# 1. Prüfen, ob Rosie da ist

if [ -f "$WALLPAPER" ]; then

    # Farben generieren & Wallpaper setzen

    wal -q -i "$WALLPAPER"

    swww img "$WALLPAPER" --transition-step 20 --transition-fps 60 --transition-type wipe

    echo "✅ Rosie-Design geladen."

else

    echo "⚠️ Rosie nicht gefunden, lade Zufallsbild..."

    WALLPAPER=$(find "$HOME/Pictures/Wallpapers" -type f | shuf -n 1)

    [ -n "$WALLPAPER" ] && wal -q -i "$WALLPAPER" && swww img "$WALLPAPER"

fi


# 2. CSS REPARIEREN (Wichtig für deine Pfade!)

if [ ! -f "${WAYBAR_STYLE}.bak" ]; then

    cp "$WAYBAR_STYLE" "${WAYBAR_STYLE}.bak"

fi

sed "s|__USER__|$USER|g" "${WAYBAR_STYLE}.bak" > "$WAYBAR_STYLE"

sed -i "s|__HOME__|$HOME|g" "$WAYBAR_STYLE"


# 3. Waybar sicher neu starten

killall waybar 2>/dev/null

sleep 0.5

waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &
