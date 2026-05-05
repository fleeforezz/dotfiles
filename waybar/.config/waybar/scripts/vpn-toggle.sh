#!/bin/bash

INTERFACE="HomeLab"

# Check status (WireGuard-native)
if wg show "$INTERFACE" &>/dev/null; then
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