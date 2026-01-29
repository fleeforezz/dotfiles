#!/bin/bash

status=$(playerctl -p spotify status 2>/dev/null)
if [ "$status" = "Playing" ]; then
    icon=""
elif [ "$status" = "Paused" ]; then
    icon=""
else
    icon="󰓛"
fi

metadata=$(playerctl -p spotify metadata --format '{{ title }} - {{ artist }}' 2>/dev/null)

if [ -n "$metadata" ]; then
    echo "$icon $metadata"
else
    echo ""
fi