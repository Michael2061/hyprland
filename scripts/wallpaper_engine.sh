#!/bin/bash

# Pfade
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
LOG_FILE="$HOME/waybar_error.log"

echo "--- LAPTOP BOOT LOG: $(date) ---" > "$LOG_FILE"

# 1. Wallpaper sofort (das funktioniert meist ohne Probleme)
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)
swww-daemon &> /dev/null &
sleep 2
swww img "$WALLPAPER" --transition-type wipe >> "$LOG_FILE" 2>&1
wal -i "$WALLPAPER" >> "$LOG_FILE" 2>&1
sed -i "s|__HOME__|$HOME|g" "$WAYBAR_STYLE" 2>> "$LOG_FILE"

# 2. Die Waybar-Schleife (Hintergrund-Prozess)
(
    for i in {1..20}; do
        # --- HIER DIESEN BLOCK ANPASSEN/ERSETZEN ---
        echo "🚀 Versuch $i: Starte Waybar..." >> "$LOG_FILE"

        # Tastatur-Layout auf Deutsch erzwingen
        hyprctl keyword input:kb_layout de >> "$LOG_FILE" 2>&1

        # Radikal aufräumen
        killall -9 waybar 2>/dev/null

        # WICHTIG: Hier geben wir dem System 3-5 Sekunden Pause
        sleep 5

        # Waybar starten
        waybar 2>> "$LOG_FILE" &
        # ------------------------------------------

        # 8 Sekunden warten: Bleibt sie offen?
        sleep 8

        if pgrep -x "waybar" > /dev/null; then
            echo "✅ ERFOLG: Waybar läuft nach Versuch $i!" >> "$LOG_FILE"
            exit 0
        fi

        echo "⚠️ Versuch $i abgestürzt (Broken Pipe). Warte auf Treiber..." >> "$LOG_FILE"
        sleep 3
    done
) &

echo "✅ Skript im Hintergrund gestartet." >> "$LOG_FILE"
