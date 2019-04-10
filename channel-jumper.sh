#!/bin/bash

# Jump Chrome OS Channels - switch to newer or older Chrome OS channels without USB recovery.

# Run this script on a Chromebook:
# 1. Put Chromebook in developer mode - https://www.chromium.org/chromium-os/poking-around-your-chrome-os-device
# 2. Log into device. Press CTRL+ALT+T to open crosh shell.
# 3. Type "shell" to enter Bash shell.
# 4. Type:
#      bash <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/channel-jumper.sh)

get_val_from_file() {
  val=$1
  filename=$2
  return `cat $filename | grep $val | awk -F= '{print $2}'`

os_version=$( get_val_from_file /etc/lsb-release CHROMEOS_RELEASE_VERSION )
browser_version=$( get_val_from_file /etc/lsb-release CHROMEOS_RELEASE_CHROME_MILESTONE )
track=$( get_val_from_file /etc/lsb-release CHROMEOS_RELEASE_TRACK )
echo -e "You are running:\n Chrome OS $os_version\n Browser   $browser_version\nChannel:   $track\n\n"
new_track=$( get_val_from_file /mnt/stateful/etc/lsb-release CHROMEOS_RELEASE_TRACK )
echo -e "Devices is configured to update on $new_track"
