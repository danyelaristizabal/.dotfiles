#!/usr/bin/env bash
sudo powertop --auto-tune
echo "powertop tuned"

sudo tlp start
echo "tlp started"

sudo envycontrol -s integrated 
echo "GPU on integrated"

echo "Restarting"
sleep 1 

sudo shutdown -r now 

