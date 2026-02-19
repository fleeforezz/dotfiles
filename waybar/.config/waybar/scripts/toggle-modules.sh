#!/usr/bin/env bash

PID=$(pgrep -x waybar)

if [ -f /tmp/waybar_minimal ]; then
    rm /tmp/waybar_minimal
    pkill waybar
    waybar &
else
    touch /tmp/waybar_minimal.jsonc
    pkill waybar
    waybar -c ~/.config/waybar/config-minimal.jsonc &
fi
