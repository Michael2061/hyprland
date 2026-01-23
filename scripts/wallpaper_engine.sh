#!/bin/bash

# Pfade
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
LOG_FILE="$HOME/waybar_error.log"

# Log-Datei komplett leeren und neu starten
echo "--- NEUSTART LOG: $(date) ---" > "$LOG_FILE"

# 1. Bild wählen
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)
if [ -z "$WALLPAPER" ]; then
    echo "❌ Fehler: Keine Bilder gefunden!" >> "$LOG_FILE"
    exit 1
fi

# 2. Hintergrund & Farben
echo "🖼️ Setze Wallpaper: $WALLPAPER" >> "$LOG_FILE"
swww-daemon &> /dev/null &
sleep 1
swww img "$WALLPAPER" --transition-type wipe >> "$LOG_FILE" 2>&1
wal -i "$WALLPAPER" >> "$LOG_FILE" 2>&1

# 3. Pfade fixen
sed -i "s|__HOME__|$HOME|g" "$WAYBAR_STYLE" 2>> "$LOG_FILE"

# 4. DIE SCHLEIFE (Das muss im Log auftauchen!)
echo "🔄 Starte Waybar-Überwachung..." >> "$LOG_FILE"

for i in {1..10}; do
    echo "-------------------------------------" >> "$LOG_FILE"
    echo "🚀 STARTVERSUCH NR. $i um $(date)" >> "$LOG_FILE"

    # Radikal aufräumen
    killall -9 waybar 2>/dev/null
    sleep 2

    # Tastatur erzwingen
    hyprctl keyword input:kb_layout de >> "$LOG_FILE" 2>&1

    # WAYBAR START (Wichtig: mit nohup und disown, damit das Skript nicht mitstirbt)
    nohup waybar >> "$LOG_FILE" 2>&1 &

    # Dem System Zeit geben, die Broken Pipe zu werfen
    sleep 10

    if pgrep -x "waybar" > /dev/null; then
        echo "✅ ERFOLG: Waybar läuft stabil in Versuch $i!" >> "$LOG_FILE"
        # Wir sind fertig, beende die Schleife
        break
    else
        echo "⚠️ FEHLSCHLAG: Versuch $i abgestürzt (Broken Pipe)." >> "$LOG_FILE"
        echo "Versuche es in 5 Sekunden erneut..." >> "$LOG_FILE"
        sleep 5
    fi
done
