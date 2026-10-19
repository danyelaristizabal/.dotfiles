#!/bin/bash

used=$(hyprctl workspaces -j | jq '.[].id' | sort -n)
for i in $(seq 1 20); do
    if ! grep -q -w "$i" <<< "$used"; then
        hyprctl dispatch movetoworkspace $i
        exit 0
    fi
done
