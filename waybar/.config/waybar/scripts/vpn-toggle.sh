#!/usr/bin/env bash

if ip link show HomeLab > /dev/null 2>&1; then
    sudo wg-quick down HomeLab && notify-send "WireGuard" "HomeLab Disconnected" -i network-vpn
else
    sudo wg-quick up HomeLab && notify-send "WireGuard" "HomeLab Connected" -i network-vpn
fi