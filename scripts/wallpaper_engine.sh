#!/bin/bash

# Pfade
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
LOG_FILE="$HOME/waybar_error.log"

# 1. Log-Datei bei jedem Start NEU erstellen
echo "--- System-Start: $(date) ---\" > "$LOG_FILE"

# 2. Prüfen, ob das Skript bereits läuft
if pgrep -x "wallpaper_engine.sh" | grep -qv $$; then
    echo "Skript läuft bereits, breche ab." >> "$LOG_FILE"
    exit 1
fi

# 3. Wallpaper & Farben
pgrep swww-daemon > /dev/null || swww-daemon &
sleep 0.5

WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
    echo "FEHLER: Kein Wallpaper gefunden in $WALLPAPER_DIR" >> "$LOG_FILE"
    exit 1
fi

swww img "$WALLPAPER" --transition-type wipe &
wal -i "$WALLPAPER" -q

# --- HIER IST DIE GEÄNDERTE ZEILE ---
# Wir nutzen $USER (Systemvariable), um __USER__ im CSS zu ersetzen
sed -i "s|__USER__|$USER|g" "$WAYBAR_STYLE"
# ------------------------------------

# 4. Tastatur auf DE
hyprctl keyword input:kb_layout de

# 5. Waybar NEU STARTEN
killall waybar 2>/dev/null
waybar &

echo "Setup erfolgreich abgeschlossen: $WALLPAPER" >> "$LOG_FILE"
