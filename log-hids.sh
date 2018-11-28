#!/bin/bash

# Log HIDs - creates a /var/log/hids.log file with current list of USB devices every 1 sec

# Run this script on a Chromebook:
# 1. Put Chromebook in developer mode - https://www.chromium.org/chromium-os/poking-around-your-chrome-os-device
# 2. Log into device. Press CTRL+ALT+T to open crosh shell.
# 3. Type "shell" to enter Bash shell.
# 4. Type:
#      bash <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/log-hids.sh)

# Make SSD read/write if it's not
source <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/enable_rw_ssd.sh)

echo "Getting xxd binary for editing..."
echo
sudo wget --quiet -O /etc/init/log-hids.conf https://raw.githubusercontent.com/jay0lee/cros-scripts/master/log-hids.conf
echo
echo "Enabled HID logging in /var/log/hids.log. Please reboot for logging to take effect."
