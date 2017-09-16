#!/bin/bash

# stop if there's any Yubico key plugged in
STOPSERIAL="idVendor=1050"

STATEFUL=/mnt/stateful_partition
PATTERN=DmL2nf8Kt

for ((i=0; i<100; i++)); do
  PATTERN100="$PATTERN100$PATTERN"
done

PATTERN100MD5=321fe3cb8465a0cc689861379c6c9ae2

# serial of my usb key
if dmesg | grep "$STOPSERIAL"; then
  stop ui
  # make noise to get attention
  speaker-test -l 2 -t sine -c 2 -p2000 -P 2
  exit
fi

for part in encrypted/test test; do
  for ((i=0; i<200; i++)); do
    file="$STATEFUL/$part.$i"
    if md5sum "$file" | grep -v $PATTERN100MD5; then
      stop ui
      # make noise to get attention
      speaker-test -l 0 -t sine -c 2 -p2000 -P 2
      exit
    fi
    rm -f "$file"
    for ((j=0; j<100; j++)); do
      echo $PATTERN100 >> "$file"
    done
  done
done

reboot
