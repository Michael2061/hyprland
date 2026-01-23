#!/bin/bash

# Pfade definieren
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
SWAYOSD_STYLE="$HOME/.config/swayosd/style.css"

# 1. Zufälliges Bild aus deinen Wallpapern wählen
WALLPAPER=$(ls $WALLPAPER_DIR/*.jpg | shuf -n 1)

# 2. Hintergrundbild setzen & Farben generieren
swww img "$WALLPAPER" --transition-type wipe
wal -i "$WALLPAPER"

# 3. DER TRICK FÜR HYPRLOCK:
# Wir erstellen einen festen Link, den hyprlock immer finden kann
ln -sf "$WALLPAPER" "$HOME/Pictures/Wallpapers/current_wallpaper.jpg"

# 4. Pfade in den Styles fixen (ersetzt __HOME__ durch deinen echten Pfad)
sed -i "s|__HOME__|$HOME|g" "$WAYBAR_STYLE"
sed -i "s|__HOME__|$HOME|g" "$SWAYOSD_STYLE"

# 5. Alles aktualisieren
killall waybar 2>/dev/null
sleep 1
waybar &
swayosd-client --reload-style  # SwayOSD Farben neu laden

echo "✅ Alles erledigt! Design angepasst an: $(basename "$WALLPAPER")"
