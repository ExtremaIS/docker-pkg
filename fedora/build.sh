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
put_info "Upgrading installed packages"
dnf upgrade -y
put_info "Installing packages"
dnf install -y \
  automake \
  gcc \
  git \
  gnupg2 \
  make \
  perl \
  rpm-build \
  rpm-devel \
  rpmdevtools \
  rpmlint

put_heading "Configure OS"
put_info "Configuring sudo"
sed -i '/^%wheel/s/ALL$/NOPASSWD:ALL/' "/etc/sudoers"

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
  --groups "wheel" \
  "docker"
put_info "Setting password"
echo "docker:docker" | chpasswd

put_heading "Clean up"
put_info "Clean package index"
dnf clean all
put_info "Removing build script"
rm /tmp/build.sh
