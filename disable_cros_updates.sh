
#!/bin/bash

# Disable CrOS Updates - prevents Chrome OS from updating by faking a very large version #

# Run this script on a Chromebook:
# 1. Put Chromebook in developer mode - https://www.chromium.org/chromium-os/poking-around-your-chrome-os-device
# 2. Log into device. Press CTRL+ALT+T to open crosh shell.
# 3. Type "shell" to enter Bash shell.
# 4. Type:
#      bash <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/disable_cros_updates.sh)

sudo mkdir -p /mnt/stateful_partition/etc
sudo bash -c 'echo "CHROMEOS_RELEASE_VERSION=99999.9.9" > /mnt/stateful_partition/etc/lsb-release'

echo "Disabled Chrome OS updates. Delete /mnt/stateful_partition/etc/lsb-release file to re-enable."
