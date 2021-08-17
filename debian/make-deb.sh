#!/bin/bash

set -o errexit
set -o nounset
#set -o xtrace

##############################################################################
# Library

term_bold="### "
term_reset=" ###"

if command -v tput >/dev/null 2>&1 ; then
  term_bold="$(tput bold)"
  term_reset="$(tput sgr0)"
fi

die () {
  echo "error: ${*}" >&2
  exit 1
}

section () {
  echo "${term_bold}${*}${term_reset}"
}

##############################################################################
# Parse Arguments

if [ "$#" -ne "1" ] ; then
  echo "usage: ${0} PROJECT-VERSION.tar.xz" >&2
  exit 2
fi

pkg_source="${1}"
pkg_dir="${pkg_source%.tar.xz}"
test "${pkg_dir}" != "${pkg_source}" \
  || die "invalid source filename: ${pkg_source}"
pkg_version="${pkg_dir##*-}"
test "${pkg_version}" != "${pkg_dir}" \
  || die "invalid source filename: ${pkg_source}"
pkg_name="${pkg_dir%-*}"

##############################################################################
# Confirm Environment

test -n "${DEBFULLNAME}" || die "DEBFULLNAME not set"
test -n "${DEBEMAIL}" || die "DEBEMAIL not set"

arch="$(dpkg --print-architecture)"

test -d "/host" || die "/host not mounted"
test -f "/host/${pkg_source}" || die "source not found: ${pkg_source}"

##############################################################################
# Main

section "Unpacking source"
cd "/tmp"
tar -Jxf "/host/${pkg_source}"
test -d "${pkg_dir}" || die "source directory not found: ${pkg_dir}"
cd "${pkg_dir}"
test -d "dist/deb" || die "dist/deb directory not found"

section "Preparing package source"
dh_make --single --yes -f "/host/${pkg_source}"
cd "debian"
rm -rf README.* "${pkg_name}"* ./*.ex "source"
if [ ! -f "compat" ] ; then
  echo "11" > "compat"
fi
cp -r ../dist/deb/* .
sed -i "s/^  \\*.*/  * Release ${pkg_version}/" "changelog"
sed -i "s/{{ARCH}}/${arch}/" "control"
if [ -f "Makefile" ] ; then
  mv "Makefile" ..
fi
cd ..

section "Building .deb package"
dpkg-buildpackage -us -uc

section "Copying build artifacts"
cd "/tmp"
rm -rf "${pkg_dir}"
cp "${pkg_name}"* "/host"
