#!/bin/bash

INTERFACE="HomeLab"

# Check status
if ip link show "$INTERFACE" 2>/dev/null | grep -q "state UP"; then
    status="connected"
    text=" VPN"
else
    status="disconnected"
    text=" VPN"
fi

# Toggle action
if [ "$1" = "toggle" ]; then
    if [ "$status" = "connected" ]; then
        sudo wg-quick down "$INTERFACE"
    else
        sudo wg-quick up "$INTERFACE"
    fi
    exit 0
fi

# Output for Waybar
echo "{\"text\": \"$text\", \"class\": \"$status\", \"tooltip\": \"Interface: $INTERFACE\"}"