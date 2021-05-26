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

test -n "${RPMFULLNAME}" || die "RPMFULLNAME not set"
test -n "${RPMEMAIL}" || die "RPMEMAIL not set"

arch="$(arch)"

[ -d "/host" ] || die "/host not mounted"
[ -f "/host/${pkg_source}" ] || die "source not found: ${pkg_source}"

##############################################################################
# Main

section "Copying source"
rpmdev-setuptree
cp "/host/${pkg_source}" "/home/docker/rpmbuild/SOURCES"

section "Building source RPM"
cd "/tmp"
tar -Jxf "/host/${pkg_source}" "${pkg_dir}/dist/rpm/${pkg_name}.spec" \
  || die "${pkg_dir}/dist/rpm/${pkg_name}.spec not found"
sed \
  -e "s/{{ARCH}}/${arch}/" \
  -e "s/{{VERSION}}/${pkg_version}/g" \
  -e "s/{{DATE}}/$(env LC_ALL=C date '+%a %b %d %Y')/" \
  -e "s/{{RPMFULLNAME}}/${RPMFULLNAME}/" \
  -e "s/{{RPMEMAIL}}/${RPMEMAIL}/" \
  "${pkg_dir}/dist/rpm/${pkg_name}.spec" \
  > "${pkg_name}.spec"
rpmbuild -bs "${pkg_name}.spec"

section "Building binary RPM"
rpmbuild --rebuild "/home/docker/rpmbuild/SRPMS/"*".src.rpm"

section "Copying build artifacts"
cp "/home/docker/rpmbuild/SRPMS/"*".src.rpm" "/host"
cp "/home/docker/rpmbuild/RPMS/${arch}/"*".rpm" "/host"
