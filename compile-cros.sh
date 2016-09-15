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

metadata_url="http://metadata.google.internal/computeMetadata/v1/instance/attributes/"

# Config for new users
echo 'export GOROOT=/usr/local/go' >> /etc/skel/.bashrc
echo 'export GOPATH=$HOME/go' >> /etc/skel/.bashrc
echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> /etc/skel/.bashrc
mkdir /etc/skel/go
cat <<EOT >> /etc/skel/.profile
if [ \! -f ~/.first-login-script-ran ]
then
  echo "Installing GoLang GCP 2.0 Connector..."
  go get -v -u -ldflags "-X github.com/google/cups-connector/lib.BuildDate=\`date +%Y.%m.%d\`" github.com/google/cloud-print-connector/...
  echo
  echo "Initializing connector..."
  gcp-connector-util init --log-level DEBUG
  echo
  gcp_command="gcp-cups-connector --config-filename \${HOME}/gcp-cups-connector.config.json --log-to-console"
  touch ~/.first-login-script-ran
  echo "Starting connector with \$gcp_command"
  \$gcp_command
fi
EOT

# start by making sure all installed packages
# are up to date.
export DEBIAN_FRONTEND=noninteractive
apt-get update
#apt-get -y dist-upgrade

# install the packages we need. For some reason it
# fails every now and again so loop until success
packages="git-core gitk git-gui subversion curl"
echo "installing $packages"
until apt-get -y install $packages
do
  echo "failed to install packages, sleeping and trying again"
  sleep 10
  apt-get update
done

git config --global user.email "jay0lee@gmail.com"
git config --global user.name "Jay Lee"

git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

export PATH=`pwd`/depot_tools:"$PATH"

cd /tmp
cat > ./sudo_editor <<EOF
#!/bin/sh
echo Defaults \!tty_tickets > \$1          # Entering your password in one shell affects all shells 
echo Defaults timestamp_timeout=180 >> \$1 # Time between re-requesting your password, in minutes
EOF
chmod +x ./sudo_editor 
sudo EDITOR=./sudo_editor visudo -f /etc/sudoers.d/relax_requirements

mkdir -p ${HOME}/chromiumos

cd ${HOME}/chromiumos
repo init -u https://chromium.googlesource.com/chromiumos/manifest.git --repo-url https://chromium.googlesource.com/external/repo.git -g minilayout
repo sync

cros_sdk --download

cros_sdk -- ./setup_board --board=link --default

cros_sdk -- ./set_shared_user_password.sh chronos

cros_sdk -- ./build_packages

cros_sdk -- ./build_image --noenable_rootfs_verification dev
