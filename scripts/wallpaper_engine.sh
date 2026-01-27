#!/bin/bash

# Pfade
WAYBAR_CONFIG="$HOME/.config/waybar/config"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
WALLPAPER="$HOME/Pictures/Wallpapers/rosie.png"

echo "🎨 Rosie-Engine: Synchronisiere alles..."

# 1. Prüfen, ob Bild da ist & Pywal Farben generieren
if [ -f "$WALLPAPER" ]; then
    wal -q -i "$WALLPAPER"
    swww img "$WALLPAPER" --transition-step 20 --transition-fps 60 --transition-type wipe
else
    WALLPAPER=$(find "$HOME/Pictures/Wallpapers" -type f \( -name "*.png" -o -name "*.jpg" \) | shuf -n 1)
    [ -n "$WALLPAPER" ] && wal -q -i "$WALLPAPER" && swww img "$WALLPAPER"
fi

# 2. Hyprland Farben exportieren
# Wir nehmen die Hex-Farbe von Pywal und machen sie für Hyprland lesbar
COLOR_VAL=$(cat "$HOME/.cache/wal/colors" | sed -n '2p' | sed 's/#//')
echo "\$color1 = rgb($COLOR_VAL)" > "$HOME/.cache/wal/colors-hyprland.conf"

# 3. Cache für SDDM/Hyprlock (Ohne Sudo)
cp "$WALLPAPER" "$HOME/.cache/current_wallpaper.png"
cp "$WALLPAPER" "$HOME/.cache/rosie_avatar.png"

# 4. Waybar CSS Pfade fixen (Ersetzt __USER__ durch echten Namen)
if [ -f "$WAYBAR_STYLE" ]; then
    sed -i "s|/home/[^/]*|/home/$USER|g" "$WAYBAR_STYLE"
    # Falls __USER__ noch als Platzhalter drin ist:
    sed -i "s|__USER__|$USER|g" "$WAYBAR_STYLE"
fi

# 5. Alles neu laden
hyprctl reload          # Lädt Hyprland Config (und die neuen Farben) neu
killall waybar 2>/dev/null
sleep 0.5
waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &

echo "✅ Alles synchronisiert! Deine Fensterrahmen leuchten jetzt passend zum Bild."