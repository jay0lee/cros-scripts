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

sudo bash -c 'echo "--disable-policy-key-verification" >> /etc/chrome_dev.conf'
sudo bash -c 'echo "--enterprise-enrollment-skip-robot-auth" >> /etc/chrome_dev.conf'
sudo bash -c 'echo "--device-management-url=$policy_url" >> /etc/chrome_dev.conf'
echo
restart-ui
echo "Switched policy to pull from:"
echo
echo $custom_url
echo
echo "you can now switch back to UI to test custom policy.""
