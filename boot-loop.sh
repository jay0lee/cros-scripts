#!/bin/bash

# stop if there's any Yubico key plugged in
STOPSERIAL="idVendor=1050"

STATEFUL=/mnt/stateful_partition
PATTERN=DmL2nf8Kt

for ((i=0; i<100; i++)); do
  PATTERN100="$PATTERN100$PATTERN"
done

PATTERN100MD5=d5443cdc04711d0317a2668a080bf659

# serial of my usb key
if dmesg | grep "$STOPSERIAL"; then
  stop ui
  exit 0
fi

for part in encrypted/test test; do
  for ((i=0; i<100; i++)); do
    file="$STATEFUL/$part.$i"
    if md5sum "$file" | grep -v $PATTERN100MD5; then
      stop ui
      exit 0
    fi
    rm -f "$file"
    for ((j=0; j<=i; j++)); do
      echo $PATTERN100 >> "$file"
    done
  done
done

#reboot
