#!/bin/bash

# Custom DM Server - configure Chrome OS to pull policy from a custom URL

# Run this script on a Chromebook:
# 1. Put Chromebook in developer mode - https://www.chromium.org/chromium-os/poking-around-your-chrome-os-device
# 2. Log into device. Press CTRL+ALT+T to open crosh shell.
# 3. Type "shell" to enter Bash shell.
# 4. Type:
#      bash <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/custom_dmserver.sh)

# Make SSD read/write if it's not
source <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/enable_rw_ssd.sh)

read -p "Which URL do you wish to use for custom policy?: " policy_url
url_line="--device-management-url=$policy_url"
sudo bash -c 'echo "--enterprise-enrollment-skip-robot-auth" >> /etc/chrome_dev.conf'
sudo bash -c "echo $url_line >> /etc/chrome_dev.conf"
echo
echo "Switched policy to pull from:"
echo
echo $policy_url
echo
echo "reboot to pull and apply new custom policy"
