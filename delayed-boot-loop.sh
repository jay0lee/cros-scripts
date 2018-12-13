  #!/bin/bash

# Delayed Boot Loop - reboots device after it's been up for N seconds

# Run this script on a Chromebook:
# 1. Put Chromebook in developer mode - https://www.chromium.org/chromium-os/poking-around-your-chrome-os-device
# 2. Log into device. Press CTRL+ALT+T to open crosh shell.
# 3. Type "shell" to enter Bash shell.
# 4. Type:
#      bash <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/delayed-boot-loop.sh) NN
#
#    where NN is the number of seconds after boot you'd like to wait before rebooting

# Make SSD read/write if it's not
source <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/enable_rw_ssd.sh)

seconds=$1
echo "Getting delayed boot loop config file..."
echo
sudo curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/delayed-boot-loop.conf > /tmp/delayed-boot-loop.conf
sudo sed -i 's/SECONDS/$seconds/g' /tmp/delayed-boot-loop.conf
sudo mv /tmp/delayed-boot-loop.conf /etc/init/
echo
echo "Enabled Boot delayed boot loop in /var/log/hids.log. Please reboot for logging to take effect."
