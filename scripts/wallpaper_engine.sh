#!/bin/bash

# Pfade
WAYBAR_CONFIG="$HOME/.config/waybar/config"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
LOG_FILE="$HOME/waybar_error.log"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# 1. Log neu starten
echo "--- Start: $(date) ---" > "$LOG_FILE"

# 2. Wallpaper auswählen & Farben generieren
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)
swww img "$WALLPAPER" --transition-type wipe &
wal -i "$WALLPAPER" -q

# 3. CSS DYNAMISCH REPARIEREN
# Wir erstellen eine Kopie der Vorlage, falls sie fehlt
if [ ! -f "${WAYBAR_STYLE}.bak" ]; then
    cp "$WAYBAR_STYLE" "${WAYBAR_STYLE}.bak"
fi

# Wir nehmen immer die saubere Vorlage und schreiben sie in die echte style.css
# Dabei ersetzen wir __USER__ durch deinen echten Namen
sed "s|__USER__|$USER|g" "${WAYBAR_STYLE}.bak" > "$WAYBAR_STYLE"
sed -i "s|__HOME__|$HOME|g" "$WAYBAR_STYLE"

# 4. Waybar sicher neu starten
killall waybar 2>/dev/null
# Wir warten kurz, bis der alte Prozess wirklich weg ist
sleep 0.5
waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &

echo "Setup erfolgreich für $USER: $WALLPAPER" >> "$LOG_FILE"
