#!/bin/bash

set -o errexit
set -o nounset
#set -o xtrace

##############################################################################
# Constants

RED="$(tput setaf 1)"
GRN="$(tput setaf 2)"
BLD="$(tput bold)"
RST="$(tput sgr0)"

##############################################################################
# Library

put_error () {
  message="${1}"
  echo "${RED}${BLD}${message}${RST}"
}

put_heading () {
  message="${1}"
  echo "${BLD}${message}${RST}"
}

put_info () {
  message="${1}"
  echo "${GRN}${message}${RST}"
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
put_info "Updating package index"
sudo apt-get update
put_info "Installing packages"
sudo apt-get install -y \
  libc6-dev \
  libffi-dev \
  libgmp-dev \
  libtinfo-dev \
  zlib1g-dev

put_heading "Install Stack"
put_info "Creating /usr/local/opt"
sudo mkdir -p "/usr/local/opt"
put_info "Downloading and installing Stack"
curl -L "https://www.stackage.org/stack/linux-x86_64" \
  | sudo tar -zx -C "/usr/local/opt"
put_info "Linking /usr/local/bin/stack"
sudo ln -s "$(ls /usr/local/opt/stack-*/stack)" /usr/local/bin/stack
put_info "Updating Stack database"
stack update

put_heading "Install GHC and hlint"
put_info "Installing current GHC and hlint"
stack install hlint
ln -s /home/docker/.local/bin /home/docker/bin

put_heading "Clean up"
put_info "Removing package index"
sudo rm -rf /var/lib/apt/lists/*
put_info "Removing build script"
sudo rm /tmp/build.sh
