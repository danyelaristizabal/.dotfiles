#!/bin/bash
# Usage: focusOrLaunchWeb.sh <url> [chrome_args...]
#
# Focus webapp window if open, otherwise launch it
# Webapp windows have class pattern like: chrome-web.domain.com__-Default

URL="$1"
shift

if [ -z "$URL" ]; then
    echo "Usage: $0 <url> [chrome_args...]"
    exit 1
fi

# Extract domain from URL for class matching
DOMAIN=$(echo "$URL" | sed -E 's|^https?://([^/]+).*|\1|')
CLASS_PATTERN="vivaldi-${DOMAIN}__-Default"

# Debug output
echo "Looking for class: $CLASS_PATTERN" >&2

# Check if webapp window exists and focus it
if hyprctl clients | grep -q "class: $CLASS_PATTERN"; then
    echo "Found existing window, focusing..." >&2
    hyprctl dispatch focuswindow "class:^($CLASS_PATTERN)$"
else
    echo "Window not found, launching..." >&2
    # Launch webapp using omarchy-launch-webapp
    omarchy-launch-webapp "$URL" "$@" &
fi
