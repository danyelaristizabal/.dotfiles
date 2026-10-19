#!/bin/bash

LOW=20     # % at which to warn for low battery
HIGH=80    # % at which to warn for high charge
BATTERY=$(acpi -b | grep -P -o '[0-9]+(?=%)')

STATUS=$(acpi -b | grep -o "Charging\|Discharging")

if [[ $STATUS == "Discharging" && $BATTERY -le $LOW ]]; then
    notify-send -u critical "Battery Low" "Battery at ${BATTERY}%"
elif [[ $STATUS == "Charging" && $BATTERY -ge $HIGH ]]; then
    notify-send -u normal "Battery High" "Battery at ${BATTERY}%. Consider unplugging."
fi

