#!/bin/bash

# Pfade definieren
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
LOG_FILE="$HOME/waybar_error.log"

echo "--- Start Log: $(date) ---" > "$LOG_FILE"

# 1. Bild wählen
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)
[ -z "$WALLPAPER" ] && echo "❌ Keine Bilder gefunden" >> "$LOG_FILE" && exit 1

# 2. Hintergrund & Farben
swww-daemon &> /dev/null &
sleep 1
swww img "$WALLPAPER" --transition-type wipe >> "$LOG_FILE" 2>&1
wal -i "$WALLPAPER" >> "$LOG_FILE" 2>&1

# 3. Pfade fixen
sed -i "s|__HOME__|$HOME|g" "$WAYBAR_STYLE" 2>> "$LOG_FILE"

# 4. Waybar Start-Loop (Fix für Broken Pipe)
echo "🔄 Starte Waybar-Überwachung..." >> "$LOG_FILE"

for i in {1..5}; do
    killall -9 waybar 2>/dev/null
    sleep 1

    # Tastatur auf Deutsch erzwingen
    if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        hyprctl keyword input:kb_layout de >> "$LOG_FILE" 2>&1
    fi

    echo "🚀 Startversuch $i..." >> "$LOG_FILE"
    (waybar 2>> "$LOG_FILE" &)

    sleep 5
    if pgrep -x "waybar" > /dev/null; then
        echo "✅ Waybar läuft nach Versuch $i!" >> "$LOG_FILE"
        break
    else
        echo "⚠️ Versuch $i fehlgeschlagen (Broken Pipe?), probiere es erneut..." >> "$LOG_FILE"
        sleep 2
    fi
done

echo "--- Log Ende ---" >> "$LOG_FILE"
