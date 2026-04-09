#!/bin/bash

status=$(playerctl -p spotify status 2>/dev/null)
if [ "$status" = "Playing" ]; then
    icon="<span size='12pt'></span>"
elif [ "$status" = "Paused" ]; then
    icon="<span size='12pt'></span>"
else
    icon="󰓛"
fi

metadata=$(playerctl -p spotify metadata --format '{{ title }} - {{ artist }}' 2>/dev/null)

if [ -n "$metadata" ]; then
    echo "$icon $metadata"
else
    echo "Nothing playing"
fi