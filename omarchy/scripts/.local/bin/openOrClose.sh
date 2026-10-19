#!/bin/bash
# Usage: openOrClose.sh <window_class_regex> <launch_command>
#
CLASS_NAME="$1"
shift

pgrep -x $CLASS_NAME >/dev/null && pkill $CLASS_NAME || $CLASS_NAME &
