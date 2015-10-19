#!/bin/bash

# Run this script on a Chromebook:
# 1. Put Chromebook in developer mode - https://www.chromium.org/chromium-os/poking-around-your-chrome-os-device
# 2. Log into device. Press CTRL+ALT+T to open crosh shell.
# 3. Type "shell" to enter Bash shell.
# 4. Type:
#      bash <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/whitelist_extension_for_pub_sesssion.sh)

function patch_strings_in_file() {
    local FILE="$1"
    local PATTERN="$2"
    local REPLACEMENT="$3"

    # Find all unique strings in FILE that contain the pattern
    HASSTRING=$(grep ${PATTERN} ${FILE})

    if [ "${HASSTRING}" != "" ] ; then
        echo "File '${FILE}' contain strings with '${PATTERN}' in them:"

        OLD_STRING=${PATTERN}
        NEW_STRING=${REPLACEMENT}

        # Create null terminated ASCII HEX representations of the strings
        OLD_STRING_HEX="$(echo -n ${OLD_STRING} | xxd -g 0 -u -ps -c 256)00"
        NEW_STRING_HEX="$(echo -n ${NEW_STRING} | xxd -g 0 -u -ps -c 256)00"

        if [ ${#NEW_STRING_HEX} -le ${#OLD_STRING_HEX} ] ; then
          # Pad the replacement string with null terminations so the
          # length matches the original string
          while [ ${#NEW_STRING_HEX} -lt ${#OLD_STRING_HEX} ] ; do
            NEW_STRING_HEX="${NEW_STRING_HEX}00"
          done

          # Now, replace every occurrence of OLD_STRING with NEW_STRING
          echo -n "Replacing ${OLD_STRING} with ${NEW_STRING}... "
          tempfile="/tmp/$(basename $0).$$.tmp"
          hexdump -ve '1/1 "%.2X"' ${FILE} | \
          sed "s/${OLD_STRING_HEX}/${NEW_STRING_HEX}/g" | \
          xxd -r -p > $tempfile
          chmod --reference ${FILE} $tempfile
          sudo mv $tempfile ${FILE}
          echo "Done!"
        else
          echo "New string '${NEW_STRING}' is longer than old" \
               "string '${OLD_STRING}'. Skipping."
        fi
    else
      echo "${PATTERN} not found in ${FILE}!"
    fi
}

# Make SSD read/write if it's not
sudo touch /root-is-readwrite &> /dev/null
if [ ! -f /root-is-readwrite ]
then
  echo "Making root filesystem read/write..."
  echo
  bash <(curl -s -S -L https://raw.githubusercontent.com/jay0lee/cros-scripts/master/enable_rw_ssd.sh)
else
  echo "Root filesystem is already read/write"
fi

# Need xxd binary which Chrome OS doesn't have to do search/replace on chrome binary
if [ ! -f /usr/bin/xxd ]
then
  echo "Getting xxd binary for editing..."
  echo
  sudo wget --quiet -O /usr/bin/xxd https://05ff04cc97a0ccd2a912d728372fdb486eb7a9d7.googledrive.com/host/0B_jQhAK09GrKZ3JMbUZucDUydVU/xxd
  sudo chmod a+rx /usr/bin/xxd
else
  echo "We already have /usr/bin/xxd binary for editing."
fi

# Prompt user for extension to allow
while :
    do
      read -p "Which extension do you want to allow in public sessions?: " allow_extension
      string_size=${#allow_extension}
      if [ $string_size -ne 32 ]
      then
        echo -e "\n\nExtension IDs should be 32 chars in length. Try again...\n\n"
        continue
      fi
      break
    done

# Prompt user for extension to replace
while :
    do
      read -p "Which extension do you want to replace? Press enter to replace Overdrive library app: " replace_extension
      if [ -z "${replace_extension}" ]
      then
        replace_extension="fnhgfoccpcjdnjcobejogdnlnidceemb" # Overdrive (library app)
      fi
      replace_string_size=${#replace_extension}
      if [ $replace_string_size -ne 32 ]
      then
        echo -e "\n\nExtension IDs should be 32 chars in length. Try again...\n\n"
        continue
      fi
      break
    done

patch_strings_in_file /opt/google/chrome/chrome $replace_extension $allow_extension

echo
echo "If the replace above succeeeded, reboot to see the changes to public session extension whitelist."
echo
