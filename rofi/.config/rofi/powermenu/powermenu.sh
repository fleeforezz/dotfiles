#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Power Menu

# Current Theme
dir="$HOME/.config/rofi/powermenu"
theme='style-launcher'  # New theme name

# Options (using nerd font icons)
shutdown='󰐥  Shutdown'
reboot='󰜉  Reboot'
lock='󰌾  Lock'
suspend='󰒲  Suspend'
logout='󰍃  Logout'

# Rofi CMD
rofi_cmd() {
	rofi -dmenu -markup-rows \
		-p "Power Menu" \
		-theme ${dir}/${theme}.rasi
}

# Confirmation CMD
confirm_cmd() {
	rofi -dmenu -markup-rows \
		-p 'Confirmation' \
		-mesg 'Are you Sure?' \
		-theme-str 'window {width: 300px; height: 250px;}' \
		-theme-str 'listview {columns: 1; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.47;}' \
		-theme ${dir}/${theme}.rasi
}

# Ask for confirmation
confirm_exit() {
	echo -e "  Yes\n  No" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
	selected="$(confirm_exit)"
	if [[ "$selected" == *"Yes"* ]]; then
		if [[ $1 == '--shutdown' ]]; then
			systemctl poweroff
		elif [[ $1 == '--reboot' ]]; then
			systemctl reboot
		elif [[ $1 == '--suspend' ]]; then
			systemctl suspend
		elif [[ $1 == '--logout' ]]; then
			hyprctl dispatch exit
		fi
	else
		exit 0
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    *"Shutdown"*)
		run_cmd --shutdown
        ;;
    *"Reboot"*)
		run_cmd --reboot
        ;;
    *"Lock"*)
		hyprlock
        ;;
    *"Suspend"*)
		run_cmd --suspend
        ;;
    *"Logout"*)
		run_cmd --logout
        ;;
esac