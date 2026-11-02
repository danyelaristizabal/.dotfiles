#!/bin/bash
# Keeps the Mac awake, even with the lid closed, while it runs on the charger,
# so it stays reachable for remote sessions. On battery, normal sleep comes back.
#
# Installed by macosx/install.sh (setup_always_on) as a root LaunchDaemon:
#   /usr/local/libexec/dotfiles-always-on
#   /Library/LaunchDaemons/com.danyelaristizabal.dotfiles.always-on.plist
# launchd runs it at boot and every 30 seconds. Log: /var/log/dotfiles-always-on.log
#
# Only power is checked, not Wi-Fi: if the Mac slept whenever Wi-Fi blinked,
# a closed-lid Mac would never come back. Staying awake lets it rejoin by itself.

set -u
PATH=/usr/bin:/bin:/usr/sbin:/sbin

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*"; }

on_ac_power() { pmset -g ps | head -n 1 | grep -q "AC Power"; }
lid_closed() { ioreg -r -k AppleClamshellState -d 1 | grep -q '"AppleClamshellState" = Yes'; }

current=$(pmset -g | awk '/SleepDisabled/ {print $2}')
current=${current:-0}

if on_ac_power; then
    if [ "$current" != "1" ]; then
        pmset -a disablesleep 1 && log "on charger: sleep disabled"
    fi
else
    if [ "$current" != "0" ]; then
        pmset -a disablesleep 0 && log "on battery: sleep re-enabled"
        # Unplugged with the lid shut (e.g. into a bag): sleep now instead of running hot
        if lid_closed; then
            log "lid closed on battery: sleeping now"
            pmset sleepnow
        fi
    fi
fi
