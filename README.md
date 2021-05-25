# `docker-pkg`

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

* [Overview](#overview)
* [Images](#images)
    * [`extremais/pkg-debian:buster`](#extremais-pkg-debian-buster)
    * [`extremais/pkg-debian-stack:buster`](#extremais-pkg-debian-stack-buster)
    * [`extremais/pkg-fedora:34`](#extremais-pkg-fedora-34)
    * [`extremais/pkg-fedora-stack:34`](#extremais-pkg-fedora-stack-34)
* [Usage](#usage)
    * [Requirements](#requirements)
    * [Building Images](#building-images)
    * [Running Containers](#running-containers)
* [Project](#project)
    * [Contribution](#contribution)
    * [License](#license)

## Overview

This repository contains the source for building [Docker][] images for
building packages for various Linux distributions.  Containers are run using
the `docker` user, which is configured to use the UID and GID of the host user
when the image is built.  This allows you to mount the host filesystem without
having to worry about file ownership issues.

[Docker]: <https://www.docker.com>

## Images

### `extremais/pkg-debian:buster`

This image contains software for building `.deb` packages on
[Debian](https://www.debian.org/)
[buster](https://www.debian.org/releases/buster/).

* [`build-essential`](https://packages.debian.org/buster/build-essential)
* [`curl`](https://packages.debian.org/buster/curl)
* [`debhelper`](https://packages.debian.org/buster/debhelper)
* [`devscripts`](https://packages.debian.org/buster/devscripts)
* [`dh-make`](https://packages.debian.org/buster/dh-make)
* [`git`](https://packages.debian.org/buster/git)
* [`sudo`](https://packages.debian.org/buster/sudo)

### `extremais/pkg-debian-stack:buster`

This image contains [Stack][https://www.haskellstack.org] for building Haskell
software.  When the image is built, the version of GHC for the latest LTS
[Stackage](https://www.stackage.org/) release is installed and
[`hlint`](https://hackage.haskell.org/package/hlint) is built in order to
decrease the number of packages that have to be built when this image is used.

This image builds on top of
[`extremais/pkg-debian:buster`](#extremais-pkg-debian-buster).

### `extremais/pkg-fedora:34`

This image contains software for building `.rpm` packages on
[Fedora](https://getfedora.org/)
[34](https://fedoraproject.org/wiki/Releases/34/ChangeSet).

* [`automake`](https://src.fedoraproject.org/rpms/automake)
* [`gcc`](https://src.fedoraproject.org/rpms/gcc)
* [`git`](https://src.fedoraproject.org/rpms/git)
* [`gnupg2`](https://src.fedoraproject.org/rpms/gnupg2)
* [`make`](https://src.fedoraproject.org/rpms/make)
* [`perl`](https://src.fedoraproject.org/rpms/perl)
* [`rpm-build`](https://pkgs.org/download/rpm-build)
* [`rpm-devel`](https://pkgs.org/download/rpm-devel)
* [`rpmdevtools`](https://src.fedoraproject.org/rpms/rpmdevtools)
* [`rpmlint`](https://src.fedoraproject.org/rpms/rpmlint)

### `extremais/pkg-fedora-stack:34`

This image contains [Stack][https://www.haskellstack.org] for building Haskell
software.  When the image is built, the version of GHC for the latest LTS
[Stackage](https://www.stackage.org/) release is installed and
[`hlint`](https://hackage.haskell.org/package/hlint) is built in order to
decrease the number of packages that have to be built when this image is used.

This image builds on top of
[`extremais/pkg-fedora:34`](#extremais-pkg-fedora-34).

## Usage

Since images are configured when built, they should be built locally, *not*
hosted on Docker Hub.

### Requirements

The following software is used:

* [Docker](https://www.docker.com)
* [GNU Make](https://www.gnu.org/software/make/)
* [ShellCheck](https://www.shellcheck.net/)

### Building Images

To see which images are currently configured, run `make help`.

```
[docker-pkg] $ make
make help                     show this help
make list                     list built/tagged images
make pkg-debian-buster        build extremais/pkg-debian:buster
make pkg-debian-stack-buster  build extremais/pkg-debian-stack:buster
make pkg-fedora-34            build extremais/pkg-fedora:34
make pkg-fedora-stack-34      build extremais/pkg-fedora-stack:34
make shellcheck               run shellcheck on scripts
```

Note that the `Makefile` does *not* automatically build parents or delete old
images when a new one is built.

For example, the following commands build the `extremais/pkg-debian:buster`
parent image and then the `extremais/pkg-debian-stack:buster` image:

```
[docker-pkg] $ make pkg-debian-buster
...
[docker-pkg] $ make pkg-debian-stack-buster
...
```

Run `make list` to list images that are built and tagged:

```
[docker-pkg] $ make list
REPOSITORY                   TAG       IMAGE ID       CREATED        SIZE
extremais/pkg-fedora-stack   34        157f6b022f82   4 hours ago    4.91GB
extremais/pkg-fedora         34        ec29596b3789   4 hours ago    703MB
extremais/pkg-debian-stack   buster    733030c6f44b   22 hours ago   4.89GB
extremais/pkg-debian         buster    ec2fbe882a7e   5 days ago     701MB
```

### Running Containers

Run a container to use a built image.  The `/host` directory within the
container may be used to mount a project directory on the host filesystem.
The `docker` user is used by default.  Use `sudo` to run commands as root.

For example, the [LiterateX][] project uses these images for building
packages.  A container is run with the `build` directory mounted, containing
the source tarball, and the build artifacts are output in the same directory.
In the `deb` command in the `Makefile`, the following command runs the
container:

```
docker run --rm -it \
  -e DEBFULLNAME="$(MAINTAINER_NAME)" \
  -e DEBEMAIL="$(MAINTAINER_EMAIL)" \
  -v $(PWD)/dist/deb/make-deb.sh:/home/docker/make-deb.sh:ro \
  -v $(PWD)/build:/host \
  extremais/pkg-debian-stack:buster \
  /home/docker/make-deb.sh "$(SRC)"
```

[Literatex]: <https://github.com/ExtremaIS/literatex-haskell#readme>

## Project

### Contribution

Issues are tracked on GitHub:
<https://github.com/ExtremaIS/docker-pkg/issues>

Issues may also be submitted via email to <bugs@extrema.is>.

### License

This project is released under the
[MIT License](https://opensource.org/licenses/MIT) as specified in the
[`LICENSE`](LICENSE) file.
