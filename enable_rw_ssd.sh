#!/bin/bash

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
