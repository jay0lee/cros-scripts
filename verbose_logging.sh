#!/bin/bash

# Verbose Logging - Add parameters to /etc/chrome_dev.conf that increase logging verbosity.

# Run this script on a Chromebook:
# 1. Put Chromebook in developer mode - https://www.chromium.org/chromium-os/poking-around-your-chrome-os-device
# 2. Log into device. Press CTRL+ALT+T to open crosh shell.
# 3. Type "shell" to enter Bash shell.
# 4. Type:
#      bash <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/verbose_logging.sh)

# Make SSD read/write if it's not
source <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/enable_rw_ssd.sh)

sudo bash -c 'echo "--log-net-log=/tmp/netlog" >> /etc/chrome_dev.conf'
sudo bash -c 'echo "--net-log-level=0" >> /etc/chrome_dev.conf'
sudo bash -c 'echo "--v=2" >> /etc/chrome_dev.conf'
sudo bash -c 'echo "vmodule=*/chromeos/login/*=2" >> /etc/chrome_dev.conf'
echo
echo "Enabled verbose logging in /etc/chrome_dev.conf. Please reboot for logging to take effect."
