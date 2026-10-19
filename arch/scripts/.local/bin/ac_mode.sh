#!/usr/bin/env bash

OUTPUT="eDP-1"
MODE="1920x1080@143.998001"

hyprctl keyword monitor "${OUTPUT},${MODE},auto,1"

rfkill unblock bluetooth 2>/dev/null || true

notify-send -u low "Screen: ${MODE}"
notify-send -u low "Bluetooth: Off"

