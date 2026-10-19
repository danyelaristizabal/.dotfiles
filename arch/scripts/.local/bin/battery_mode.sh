#!/usr/bin/env bash
# Battery profile for Hyprland
OUTPUT="eDP-1"
MODE="1920x1080@60.002998"

# Change refresh rate
hyprctl keyword monitor "${OUTPUT},${MODE},auto,1"

# Optional: Bluetooth off
rfkill block bluetooth 2>/dev/null || true

notify-send -u low "Screen: ${MODE}"
notify-send -u low "Bluetooth: On"


