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
packages="whois build-essential libcups2-dev libavahi-client-dev git bzr cups cups-pdf apache2"
echo "installing $packages"
until apt-get -y install $packages
do
  echo "failed to install packages, sleeping and trying again"
  sleep 10
  apt-get update
done

# Install Go
typeset VER=`curl -s https://golang.org/dl/ | grep -m 1 -o 'go\([0-9]\)\+\(\.[0-9]\)\+'`
curl -O https://storage.googleapis.com/golang/$VER.linux-amd64.tar.gz
tar xvf $VER.linux-amd64.tar.gz
chown -R root:root ./go
mv go /usr/local

# Install GAM
source <(curl -s -S -L https://git.io/install-gam) -d /usr/local -l
echo 'alias gam="python /usr/local/gam/gam.py"' >> /etc/skel/.bashrc
echo '{"installed":{"client_id":"744500012322-l9k71a79e12lnu87ffqohqjl0141f22h.apps.googleusercontent.com","project_id":"jayhlee-gce-instances","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://accounts.google.com/o/oauth2/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_secret":"hlocexhhxrHWKO3iCxReaPVi","redirect_uris":["urn:ietf:wg:oauth:2.0:oob","http://localhost"]}}' > /usr/local/gam/client_secrets.json
touch /usr/local/gam/nobrowser.txt
chmod a+rwx -R /usr/local/gam

# Share PDF folder via web
echo '<meta http-equiv="refresh" content="0; url=/pdfs" />' > /var/www/html/index.html
ln -s /var/spool/cups-pdf/ANONYMOUS/ /var/www/html/pdfs

# Give jobs unique filenames
echo "Label 1" >> /etc/cups/cups-pdf.conf

# Reboot or restart services as required
# so that upgrades and config changes are applied
if [ -a /var/run/reboot-required ]
then
  reboot
else
  service cups restart
fi
