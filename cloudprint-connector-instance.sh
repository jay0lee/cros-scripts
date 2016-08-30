#!/bin/bash

# make sure we only run once at VM creation
# additional reboots exit immediately
if [ -a /root/.startup-script-ran ]
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
if [ -a ~/.first-login-script-ran ]
then
  echo "Installing GoLang GCP 2.0 Connector..."
  go get -v github.com/google/cloud-print-connector/...
  echo
  echo "Initializing connector..."
  gcp-connector-util init
  echo
  gcp_command="gcp-cups-connector --config-filename ~/gcp-cups-connector.config.json"
  touch ~/.first-login-script-ran
  echo "Starting connector with $gcp_command"
  $gcp_command
fi
EOT

# start by making sure all installed packages
# are up to date.
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y dist-upgrade

# Create gcp user

# Install Go
curl -O https://storage.googleapis.com/golang/go1.7.linux-amd64.tar.gz
tar xvf go1.7.linux-amd64.tar.gz
chown -R root:root ./go
mv go /usr/local

# install the packages we need. For some reason it
# fails every now and again so loop until success
packages="whois build-essential libcups2-dev libavahi-client-dev git bzr cups cups-pdf"
echo "installing $packages"
until apt-get -y install $packages
do
  echo "failed to install packages, sleeping and trying again"
  sleep 10
  apt-get update
done

# Reboot or restart services as required
# so that upgrades and config changes are applied
if [ -a /var/run/reboot-required ]
then
  reboot
fi
