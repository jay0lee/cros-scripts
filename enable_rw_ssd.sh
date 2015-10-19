#!/bin/bash


# Run this script on a Chromebook:
# 1. Put Chromebook in developer mode - https://www.chromium.org/chromium-os/poking-around-your-chrome-os-device
# 2. Log into device. Press CTRL+ALT+T to open crosh shell.
# 3. Type "shell" to enter Bash shell.
# 4. Type:
#      bash <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/enable_rw_ssd.sh)

sudo /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --partitions "2 4"
sudo mount -o remount,rw /
if [ $? -ne 0 ]; then
  echo
  echo
  echo
  echo "Reboot needed to enable OS writing. Please re-run script after a restart."
  echo "Rebooting in 5 seconds..."
  sleep 5
  sudo reboot
fi
