#!/bin/bash
# Usage: focusOrLunch.sh <window_class_regex> <launch_command>
#
CLASS_REGEX="$1"
shift

if [ $# -eq 0 ]; then
    # No launch command provided, use class regex as command
    LAUNCH_CMD="$CLASS_REGEX"
    if hyprctl clients | grep -q "class: $CLASS_REGEX"; then
        hyprctl dispatch focuswindow "class:^($CLASS_REGEX)$"
    else
        "$LAUNCH_CMD" &
    fi
else
    if hyprctl clients | grep -q "class: $CLASS_REGEX"; then
        hyprctl dispatch focuswindow "class:^($CLASS_REGEX)$"
    else
        "$@" &
    fi
fi
