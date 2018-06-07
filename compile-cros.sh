#!/bin/bash

# make sure we only run once at VM creation
# additional reboots exit immediately
if [ -f /root/.startup-script-ran ]
then
  echo "startup script already ran once"
  exit 0
else
  touch /root/.startup-script-ran
fi

useradd -m cros
adduser cros google-sudoers

metadata_url="http://metadata.google.internal/computeMetadata/v1/instance/attributes/"
board=`curl --fail $metadata_url/board -H "Metadata-Flavor: Google"`
if [ -z $board ]
then
  board="caroline"
fi
branch=`curl --fail $metadata_url/branch -H "Metadata-Flavor: Google"`
if [ ! -z  $branch ]
then
  branch_flag="-b $branch"
else
  branch="master"
  branch_flag=""
fi
export ACCEPT_LICENSES="*"
export ACCEPT_LICENSE=$ACCEPT_LICENSES

echo "BUILDSCRIPT: building for board $board and branch $branch..."

# start by making sure all installed packages
# are up to date.
export DEBIAN_FRONTEND=noninteractive
apt update
apt -y upgrade

# install the packages we need. For some reason it
# fails every now and again so loop until success
packages="git-core gitk git-gui curl lvm2 thin-provisioning-tools python-pkg-resources python-virtualenv python-oauth2client"
echo "installing $packages"
until apt -y install $packages
do
  echo "BUILDSCRIPT: failed to install packages, sleeping and trying again"
  sleep 10
  apt update
done

sudo -i -u cros bash << EOF
  echo "BUILDSCRIPT: setting git defaults..."
  git config --global color.ui false 
  git config --global user.email "jay0lee@gmail.com"
  git config --global user.name "Jay Lee"
  echo "BUILDSCRIPT: cloning depot_tools..."
  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
  mkdir -p ~/chromiumos
  cd ~/chromiumos
  echo "BUILDSCRIPT: repo init..."
  /home/cros/depot_tools/repo init \
    -u https://chromium.googlesource.com/chromiumos/manifest.git \
    --repo-url https://chromium.googlesource.com/external/repo.git $branch_flag
  echo "BUILDSCRIPT: repo sync..."
  /home/cros/depot_tools/repo sync -j8
  echo "BUILDSCRIPT: cros_sdk --download..."
  /home/cros/depot_tools/cros_sdk --download
  echo "BUILDSCRIPT: setup_board..."
  /home/cros/depot_tools/cros_sdk -- ./setup_board --board=$board --default
  echo "BUILDSCRIPT: set_shared_user_password..."
  /home/cros/depot_tools/cros_sdk -- ./set_shared_user_password.sh chronos
  echo "BUILDSCRIPT: build_packages..."
  /home/cros/depot_tools/cros_sdk -- ./build_packages --accept_licenses=$ACCEPT_LICENSES
  echo "BUILDSCRIPT: build_image..."
  /home/cros/depot_tools/cros_sdk -- ./build_image --noenable_rootfs_verification dev
EOF
