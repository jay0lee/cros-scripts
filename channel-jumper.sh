#!/bin/bash

# Jump Chrome OS Channels - switch to newer or older Chrome OS channels without USB recovery.

# Run this script on a Chromebook:
# 1. Put Chromebook in developer mode - https://www.chromium.org/chromium-os/poking-around-your-chrome-os-device
# 2. Log into device. Press CTRL+ALT+T to open crosh shell.
# 3. Type "shell" to enter Bash shell.
# 4. Type:
#      bash <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/channel-jumper.sh)

source /etc/lsb-release
echo -e "You are running:\n Chrome OS $CHROMEOS_RELEASE_VERSION\n Browser   $CHROMEOS_RELEASE_CHROME_MILESTONE\nChannel:   $CHROMEOS_RELEASE_TRACK\n\n"
source /mnt/stateful/etc/lsb-release
echo -e "Devices is configured to update on $CHROMEOS_RELEASE_TRACK"
