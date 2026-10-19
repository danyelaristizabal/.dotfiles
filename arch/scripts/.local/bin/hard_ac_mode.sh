#!/usr/bin/env bash
sudo envycontrol -s hybrid 
echo "GPU on hybrid"

lspci | grep -i nvidia

echo "restarting"
sudo shutdown -r now
