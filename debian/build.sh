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

if [ "$#" -gt "2" ] ; then
  put_error "usage: ${0} [USER_UID] [USER_GID]"
  exit 1
fi

USER_UID="${1:-1000}"
USER_GID="${2:-1000}"

echo "USER_UID=${USER_UID}"
echo "USER_GID=${USER_GID}"

##############################################################################
# Main

put_heading "Install OS packages"
put_info "Updating package index"
apt-get update
put_info "Upgrading installed packages"
apt-get upgrade -y
put_info "Installing packages"
apt-get install -y \
  build-essential \
  curl \
  debhelper \
  devscripts \
  dh-make \
  git \
  sudo

put_heading "Configure OS"
put_info "Configuring sudo"
sed -i '/^%sudo/s/ALL$/NOPASSWD:ALL/' "/etc/sudoers"

put_heading "Create user"
put_info "Adding group: docker (${USER_GID})"
groupadd \
  --gid "${USER_GID}" \
  "docker"
put_info "Adding user: docker (${USER_UID})"
useradd \
  --create-home \
  --shell "/bin/bash" \
  --uid "${USER_UID}" \
  --gid "${USER_GID}" \
  --groups "adm,staff,sudo" \
  "docker"
put_info "Setting password"
echo "docker:docker" | chpasswd

put_heading "Clean up"
put_info "Removing package index"
rm -rf /var/lib/apt/lists/*
put_info "Removing build script"
rm /tmp/build.sh
