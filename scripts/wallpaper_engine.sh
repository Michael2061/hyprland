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

# 4. SDDM (LOGIN SCREEN) AKTUALISIEREN
echo "🌙 Synchronisiere SDDM mit Rosie-Design..."

# 5. Hintergrundbilder für SDDM und Hyprlock vorbereiten
sudo cp "$WALLPAPER" /usr/share/sddm/themes/sugar-candy/Backgrounds/current_bg.jpg
cp "$WALLPAPER" "$HOME/.cache/current_wallpaper.png"

# 6. Die Farben und das Profilbild-Setting in die .user Datei schreiben
SDDM_USER_CONF="/usr/share/sddm/themes/sugar-candy/theme.conf.user"

echo "[General]
background=Backgrounds/current_bg.jpg
mainColor=$COLOR4
accentColor=$COLOR1
faceColor=$COLOR2
fontColor=$FOREGROUND
selectionColor=$COLOR4
HourFormat=HH:mm
DateFormat=dddd, d. MMMM yyyy
DateFontSize=22
HourFontSize=64
showRoundUserIcon=true
borderWidth=3
font=JetBrains Mono Nerd Font" | sudo tee "$SDDM_USER_CONF" > /dev/null
