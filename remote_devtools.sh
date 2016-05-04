
#!/bin/bash

# Remote devtools debugging - allows remote connectivity to Chrome dev tools for debugging kiosk session / etc.

# Run this script on a Chromebook:
# 1. Put Chromebook in developer mode - https://www.chromium.org/chromium-os/poking-around-your-chrome-os-device
# 2. Log into device. Press CTRL+ALT+T to open crosh shell.
# 3. Type "shell" to enter Bash shell.
# 4. Type:
#      bash <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/remote_devtools.sh)

# Make SSD read/write if it's not
source <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/enable_rw_ssd.sh)

sudo bash -c 'echo "--remote-debugging-port=9222" >> /etc/chrome_dev.conf'
sudo /usr/libexec/debugd/helpers/dev_features_ssh

cat >/tmp/remote-devtools.conf <<EOL
description  "start ssh for remote connection to Chrome devtools running on localhost"
author       "jay0lee@gmail.com"

start on started openssh-server
stop on stopping openssh-server
respawn

expect fork
script
  exec ssh -oStrictHostKeyChecking=no -L 0.0.0.0:9223:localhost:9222 localhost -N
end script
EOL
sudo mv /tmp/remote-devtools.conf /etc/init/
sudo chmod 644 /etc/init/remote-devtools.conf
sudo chown root.root /etc/init/remote-devtools.conf
echo
myip=`ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`
echo "Enabled remote dev tools. Reboot and try accessing http://$myip:9223 to see remote dev-tools."
