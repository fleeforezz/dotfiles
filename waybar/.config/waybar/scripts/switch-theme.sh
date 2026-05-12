#!/bin/bash

THEME_DIR="$HOME/.config/waybar/themes"
ROFI_THEME="$HOME/.config/rofi/waybar-switcher/waybar-switcher.rasi"

selected=$(find "$THEME_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort | rofi -dmenu -i -p "Waybar Theme" -theme "$ROFI_THEME")

[ -z "$selected" ] && exit

ln -sf "$THEME_DIR/$selected/config.jsonc" ~/.config/waybar/config.jsonc
ln -sf "$THEME_DIR/$selected/style.css" ~/.config/waybar/style.css

pkill waybar
waybar > /dev/null 2>&1 &

notify-send "Waybar Theme" "Switched to $selected"