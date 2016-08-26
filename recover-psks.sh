#!/bin/bash

# Recover WPA PSKs - prints out PSKs for WPA-PSK networks pushed to device via user/device policy

# Run this script on a Chromebook:
# 1. Put Chromebook in developer mode - https://www.chromium.org/chromium-os/poking-around-your-chrome-os-device
# 2. Log into device. Press CTRL+ALT+T to open crosh shell.
# 3. Type "shell" to enter Bash shell.
# 4. Type:
#      bash <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/recover-psks.sh)

echo "Device PSKs:"
sudo cat /var/cache/shill/default.profile | grep -E '^Name=|^Passphrase=' | cut -d "=" -f 2- | while read line
do
  if [[ "$line" == "default" ]]; then
    continue
  fi
  if [[ "$line" == "rot47"* ]]; then
    rotted=${line:6}
    unrotted=`echo $rotted | tr '!-~' 'P-~!-O'`
    echo " PSK:  $unrotted"
    echo
  else
    echo "SSID: $line"
  fi
done
echo
echo
echo "User PSKs:"
sudo cat /home/root/*/session_manager/policy/policy | grep -a -E '\"Passphrase\":|\"SSID\":'
