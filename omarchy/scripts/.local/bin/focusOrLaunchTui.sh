#!/bin/bash
# Usage: focusOrLaunchTui.sh <title_pattern> <class_pattern> <launch_cmd...>
#
# Focus an existing Alacritty TUI window (matching class/title)
# Otherwise launch it.

TITLE_PATTERN="$1"
CLASS_PATTERN="$2"
shift 2

if [ -z "$TITLE_PATTERN" ] || [ -z "$CLASS_PATTERN" ]; then
    echo "Usage: $0 <title_pattern> <class_pattern> <launch_cmd...>"
    exit 1
fi

echo "Looking for class='$CLASS_PATTERN' and title~='$TITLE_PATTERN'" >&2

# Check if a matching window exists
CLIENT=$(hyprctl clients -j | jq -r \
    --arg cls "$CLASS_PATTERN" \
    --arg ttl "$TITLE_PATTERN" '
    .[] | select(.class == $cls and (.title | test($ttl))) | .address' \
)

if [ -n "$CLIENT" ] && [ "$CLIENT" != "null" ]; then
    echo "Found existing TUI window ($CLIENT), focusing..." >&2
    hyprctl dispatch focuswindow address:$CLIENT
else
    echo "No matching window found, launching..." >&2
    "$@" &
fi

