#!/bin/bash

set -o errexit
set -o nounset
#set -o xtrace

##############################################################################
# Library

put_error () {
  message="${1}"
  echo "ERROR: ${message}"
}

put_heading () {
  message="${1}"
  echo "### ${message} ###"
}

put_info () {
  message="${1}"
  echo "${message}"
}

##############################################################################
# Arguments

put_heading "Configure"

if [ "$#" -gt "0" ] ; then
  put_error "usage: ${0}"
  exit 1
fi

##############################################################################
# Main

put_heading "Install Stack OS dependencies"
put_info "Installing packages"
sudo dnf install -y \
  glibc-devel \
  gmp-devel \
  libffi \
  ncurses-devel \
  zlib-devel

put_heading "Install Stack"
put_info "Creating /usr/local/opt"
sudo mkdir -p "/usr/local/opt"
put_info "Downloading and installing Stack"
curl -L "https://www.stackage.org/stack/linux-x86_64" \
  | sudo tar -zx -C "/usr/local/opt"
put_info "Linking /usr/local/bin/stack"
sudo ln -s "$(ls /usr/local/opt/stack-*/stack)" "/usr/local/bin/stack"
put_info "Updating Stack database"
stack update

put_heading "Install GHC and hlint"
put_info "Installing current GHC and hlint"
stack install hlint
ln -s "/home/docker/.local/bin/hlint" "/home/docker/bin/hlint"

put_heading "Clean up"
put_info "Clean package index"
sudo dnf clean all
put_info "Removing temporary files"
sudo rm "/tmp/build.sh"
