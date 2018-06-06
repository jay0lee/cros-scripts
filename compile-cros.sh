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

metadata_url="http://metadata.google.internal/computeMetadata/v1/instance/attributes/"
board=`curl $metadata_url/board -H "Metadata-Flavor: Google"`
branch=`curl $metadata_url/branch -H "Metadata-Flavor: Google"`
branch_flag=""
if [ ! -z  $branch ]
then
  branch_flag="-b $branch"
fi

# start by making sure all installed packages
# are up to date.
export DEBIAN_FRONTEND=noninteractive
apt-get update
#apt-get -y dist-upgrade

# install the packages we need. For some reason it
# fails every now and again so loop until success
packages="git-core gitk git-gui curl lvm2 thin-provisioning-tools python-pkg-resources python-virtualenv python-oauth2client"
echo "installing $packages"
until apt-get -y install $packages
do
  echo "failed to install packages, sleeping and trying again"
  sleep 10
  apt-get update
done

cd /tmp
cat > ./sudo_editor <<EOF
#!/bin/sh
echo Defaults \!tty_tickets > \$1          # Entering your password in one shell affects all shells 
echo Defaults timestamp_timeout=180 >> \$1 # Time between re-requesting your password, in minutes
EOF
chmod +x ./sudo_editor 
sudo EDITOR=./sudo_editor visudo -f /etc/sudoers.d/relax_requirements

sudo -i -u cros bash << EOF
  git config --global color.ui false 
  git config --global user.email "jay0lee@gmail.com"
  git config --global user.name "Jay Lee"
  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
  mkdir -p chromiumos
  /home/cros/depot_tools/repo init \
    -u https://chromium.googlesource.com/chromiumos/manifest.git \
    --repo-url https://chromium.googlesource.com/external/repo.git -g minilayout $branch_flag
  /home/cros/depot_tools/repo sync
  /home/cros/depot_tools/cros_sdk --download
  /home/cros/depot_tools/cros_sdk -- ./setup_board --board=$board --default
  /home/cros/depot_tools/cros_sdk -- ./set_shared_user_password.sh chronos
  /home/cros/depot_tools/cros_sdk -- ./build_packages
  /home/cros/depot_tools/cros_sdk -- ./build_image --noenable_rootfs_verification dev
EOF
