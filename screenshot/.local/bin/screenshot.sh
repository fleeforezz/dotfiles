#!/bin/bash

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

FILE="$DIR/$(date +%Y%m%d_%H%M%S).png"
GEOM=$(slurp) || exit 1

grim -g "$GEOM" "$FILE" &&
wl-copy < "$FILE" &&
paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga &&
notify-send "Screenshot" "Saved & copied to clipboard"
