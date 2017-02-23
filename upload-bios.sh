#!/bin/bash

# Upload BIOS - uploads Chrome OS device's firmware to Drive for safe keeping.

# Run this script on a Chromebook:
# 1. Put Chromebook in developer mode - https://www.chromium.org/chromium-os/poking-around-your-chrome-os-device
# 2. Log into device. Press CTRL+ALT+T to open crosh shell.
# 3. Type "shell" to enter Bash shell.
# 4. Type:
#      bash <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/upload-bios.sh)

fwid=`crossystem fwid`
hwid=`crossystem hwid`
now=`date +%Y%m%d-%H%M%S`
drive_filename="cros-firmware-$fwid-$now.bin"
mac_address=`/sbin/ifconfig wlan0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'`
drive_filedescription="Hardware ID: $hwid\nWLAN Mac Address: $mac_address"

client_id='252950668309.apps.googleusercontent.com'
client_secret='dK3Y2P8E4YcMkevUfj2cJOBS' # not really a secret
scope='https://www.googleapis.com/auth/drive.file'

# Store our credentials in our home directory with a file called .<script name>
my_creds=~/.firmware_upload
if [ -s $my_creds ]; then
  # if we already have a token stored, use it
  . $my_creds
  time_now=`date +%s`
else
  scope='https://www.googleapis.com/auth/drive.file'
  # Form the request URL
  # http://goo.gl/U0uKEb
  auth_url="https://accounts.google.com/o/oauth2/auth?client_id=$client_id&scope=$scope&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&access_type=online"

  echo "Please go to:"
  echo
  echo "$auth_url"
  echo
  echo "after accepting, enter the code you are given:"
  read auth_code

  # swap authorization code for access and refresh tokens
  # http://goo.gl/Mu9E5J
  auth_result=$(curl -s https://accounts.google.com/o/oauth2/token \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d "code=$auth_code" \
    -d "client_id=$client_id" \
    -d "client_secret=$client_secret" \
    -d "redirect_uri=urn:ietf:wg:oauth:2.0:oob" \
    -d "grant_type=authorization_code")
  access_token=$(echo -e "$auth_result" | \
                 grep -E '"access_token" *: *.*?[^\\]",' | \
                 awk -F'"' '{ print $4 }')
  refresh_token=$(echo -e "$auth_result" | \
                  grep -E '"refresh_token" *: *.*?[^\\]",*' | \
                  awk -F'"' '{ print $4 }')
  expires_in=$(echo -e "$auth_result" | \
               grep -E '"expires_in" *: *.*' | \
               awk -F' ' '{ print $3 }' | awk -F',' '{ print $1}')
  time_now=`date +%s`
  expires_at=$((time_now + expires_in - 60))
  echo -e "access_token=$access_token\nrefresh_token=$refresh_token\nexpires_at=$expires_at" > $my_creds
fi

# if our access token is expired, use the refresh token to get a new one
# http://goo.gl/71rN6V
if [ $time_now -gt $expires_at ]; then
  refresh_result=$(curl -s https://accounts.google.com/o/oauth2/token \
   -H 'Content-Type: application/x-www-form-urlencoded' \
   -d "refresh_token=$refresh_token" \
   -d "client_id=$client_id" \
   -d "client_secret=$client_secret" \
   -d "grant_type=refresh_token")
  access_token=$(echo -e "$refresh_result" | \
                 grep -E '"access_token" *: *.*?[^\\]",' | \
                 awk -F'"' '{ print $4 }')
  expires_in=$(echo -e "$refresh_result" | \
               grep -E '"expires_in" *: *.*' | \
               awk -F' ' '{ print $3 }' | awk -F',' '{ print $1 }')
  time_now=`date +%s`
  expires_at=$(($time_now + $expires_in - 60))
  echo -e "access_token=$access_token\nrefresh_token=$refresh_token\nexpires_at=$expires_at" > $my_creds
fi

# Dump our firmware to a file
echo -e "\nDumping firmware to temp file /tmp/$drive_filename...\n"
sudo flashrom -r /tmp/$drive_filename

# Upload the file to drive
# http://goo.gl/VV4mZJ
echo -e "\nUploading firmware to Google Drive...\n"
upload_result=$(curl https://www.googleapis.com/upload/drive/v2/files \
  -d "uploadType=media" \
  -d "prettyPrint=true" \
  -d "fields=id" \
  -H "Content-Type: application/octet-stream" \
  -H "Authorization: Bearer $access_token" \
  --data-binary @/tmp/$drive_filename)

file_id=$(echo -e "$upload_result" | \
          grep -E '^ "id" *: *.*?[^\\]",' | \
          awk -F'"' '{ print $4 }')

# Patch file name and description
# http://goo.gl/EZW93n
patch_body="{ \"title\": \"$drive_filename\", \"description\": \"$drive_filedescription\" }"
patch_url="https://www.googleapis.com/drive/v2/files/$file_id"
echo -e "\nSetting firmware filename and description...\n"
patch_result=$(curl -s $patch_url \
 -X PATCH \
 -H "Content-Type: application/json" \
 -H "Authorization: Bearer $access_token" \
 -d "$patch_body")
echo -e "All finished! Please confirm you can see:\n\n  $drive_filename\n\nin Google Drive before playing with firmware updates."
