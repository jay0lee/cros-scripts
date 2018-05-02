
#!/bin/bash

# Remote devtools debugging - allows remote connectivity to Chrome dev tools for debugging kiosk session / etc.

# Run this script on a Chromebook:
# 1. Put Chromebook in developer mode - https://www.chromium.org/chromium-os/poking-around-your-chrome-os-device
# 2. Log into device. Press CTRL+ALT+T to open crosh shell.
# 3. Type "shell" to enter Bash shell.
# 4. Type:
#      bash <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/remote_devtools.sh)
# 5. If the device is not already in read-write mode (which it probably isn't) the script will reboot your device.
# 6. Repeat steps 2-4 (same command) after the reboot.
# 7. Make sure the device is connected to an open Wifi network that allows peer-to-peer (p2p) connections).
# 8. Note the IP address of the this device (it may change). You should be able to access the remote devtools at http://<device ip>:9223

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

pre-start script
  iptables -A INPUT -p tcp --dport 9223 -j ACCEPT -w
  ip6tables -A INPUT -p tcp --dport 9223 -j ACCEPT -w
end script

post-stop script
  iptables -D INPUT -p tcp --dport 9223 -j ACCEPT -w
  ip6tables -D INPUT -p tcp --dport 9223 -j ACCEPT -w
end script

expect fork
script
  sleep 5
  exec ssh -oStrictHostKeyChecking=no -L 0.0.0.0:9223:localhost:9222 localhost -N
end script
EOL
sudo mv /tmp/remote-devtools.conf /etc/init/
sudo chmod 644 /etc/init/remote-devtools.conf
sudo chown root.root /etc/init/remote-devtools.conf
echo
myip=`ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`
echo "Enabled remote dev tools. Reboot and try accessing http://$myip:9223 to see remote dev-tools."
