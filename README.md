# `docker-pkg`

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

* [Overview](#overview)
* [Images](#images)
    * [`extremais/pkg-debian:bullseye`](#extremaispkg-debianbullseye)
    * [`extremais/pkg-debian-stack:bullseye`](#extremaispkg-debian-stackbullseye)
    * [`extremais/pkg-fedora:34`](#extremaispkg-fedora34)
    * [`extremais/pkg-fedora-stack:34`](#extremaispkg-fedora-stack34)
* [Usage](#usage)
    * [Requirements](#requirements)
    * [Building Images](#building-images)
    * [Example Usage](#example-usage)
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

All of the images use the following conventions:

* Containers are run using the `docker` user by default.  Commands can be run
  as root by using `sudo`.
* Mount the project build directory at the `/host` volume within the
  container.

### `extremais/pkg-debian:bullseye`

This image contains software for building `.deb` packages on
[Debian](https://www.debian.org/)
[bullseye](https://www.debian.org/releases/bullseye/).

* [`build-essential`](https://packages.debian.org/bullseye/build-essential)
* [`curl`](https://packages.debian.org/bullseye/curl)
* [`debhelper`](https://packages.debian.org/bullseye/debhelper)
* [`devscripts`](https://packages.debian.org/bullseye/devscripts)
* [`dh-make`](https://packages.debian.org/bullseye/dh-make)
* [`git`](https://packages.debian.org/bullseye/git)
* [`sudo`](https://packages.debian.org/bullseye/sudo)

#### `make-deb.sh`

A script for building `.deb` packages from a source tarball is installed at
`/home/docker/bin/make-deb.sh`.  Note that its use is optional.  When
different behavior is required, a custom script can be mounted and executed.

When running this script in a container, do the following:

* Set the `DEBFULLNAME` and `DEBEMAIL` environment variables.
* Mount the project build directory at `/host` (read-write).
* Pass the source tarball filename as an argument to the script.

The source tarball filename must be in `PROJECT-VERSION.tar.xz` format.  The
file must be in the mounted build directory and must contain the source code
under a directory in `PROJECT-VERSION` format.  There must be a `dist/deb`
directory under the source directory, which should include `control` and
`copyright` files at minimum.  The following variables are replaced in the
`control` file if they exist.

| Variable   | Replacement     |
| ---------- | --------------- |
| `{{ARCH}}` | OS architecture |

If `dist/deb` contains a `Makefile`, then it is used instead of the project
`Makefile` to build the package.

The build artifacts are copied to the mounted build directory.

### `extremais/pkg-debian-stack:bullseye`

This image contains [Stack][https://www.haskellstack.org] for building Haskell
software.  When the image is built, the version of GHC for the latest LTS
[Stackage](https://www.stackage.org/) release is installed and
[`hlint`](https://hackage.haskell.org/package/hlint) is built in order to
decrease the number of packages that have to be built when this image is used.

This image builds on top of
[`extremais/pkg-debian:bullseye`](#extremaispkg-debianbullseye).

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

#### `make-rpm.sh`

A script for building `.rpm` packages from a source tarball is installed at
`/home/docker/bin/make-rpm.sh`.  Note that its use is optional.  When
different behavior is required, a custom script can be mounted and executed.

When running this script in a container, do the following:

* Set the `RPMFULLNAME` and `RPMEMAIL` environment variables.
* Mount the project build directory at `/host` (read-write).
* Pass the source tarball filename as an argument to the script.

The source tarball filename must be in `PROJECT-VERSION.tar.xz` format.  The
file must be in the mounted build directory and must contain the source code
under a directory in `PROJECT-VERSION` format.  There must be a `dist/rpm`
directory under the source directory, which should include a `.spec` file in
`PROJECT.spec` format.  The following variables are replaced in the `.spec`
file if they exist.

| Variable          | Replacement                                      |
| ----------------- | ------------------------------------------------ |
| `{{ARCH}}`        | OS architecture                                  |
| `{{DATE}}`        | current date formatted for the changelog         |
| `{{RPMEMAIL}}`    | value of the `RPMEMAIL` environment variable     |
| `{{RPMFULLNAME}}` | value of the `RPMFULLNAME` environment variable  |
| `{{VERSION}}`     | project version from the source tarball filename |

If `dist/rpm` contains a `Makefile`, then it is used instead of the project
`Makefile` to build the package.

The build artifacts are copied to the mounted build directory.

### `extremais/pkg-fedora-stack:34`

This image contains [Stack][https://www.haskellstack.org] for building Haskell
software.  When the image is built, the version of GHC for the latest LTS
[Stackage](https://www.stackage.org/) release is installed and
[`hlint`](https://hackage.haskell.org/package/hlint) is built in order to
decrease the number of packages that have to be built when this image is used.

This image builds on top of
[`extremais/pkg-fedora:34`](#extremaispkg-fedora34).

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
make help                       show this help
make list                       list built/tagged images
make pkg-debian-buster          build extremais/pkg-debian:buster
make pkg-debian-stack-buster    build extremais/pkg-debian-stack:buster
make pkg-debian-bullseye        build extremais/pkg-debian:bullseye
make pkg-debian-stack-bullseye  build extremais/pkg-debian-stack:bullseye
make pkg-fedora-34              build extremais/pkg-fedora:34
make pkg-fedora-stack-34        build extremais/pkg-fedora-stack:34
make shellcheck                 run shellcheck on scripts
```

Note that the `Makefile` does *not* automatically build parents or delete old
images when a new one is built.

For example, the following commands build the `extremais/pkg-debian:bullseye`
parent image and then the `extremais/pkg-debian-stack:bullseye` image:

```
[docker-pkg] $ make pkg-debian-bullseye
...
[docker-pkg] $ make pkg-debian-stack-bullseye
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

### Example Usage

The [hr][] project uses these images for building packages.

In the `deb` command in the `Makefile`, the following command runs a container
to build a `.deb` package:

```
@docker run --rm -it \
  -e DEBFULLNAME="$(MAINTAINER_NAME)" \
  -e DEBEMAIL="$(MAINTAINER_EMAIL)" \
  -v $(PWD)/build:/host \
  extremais/pkg-debian-stack:bullseye\
  /home/docker/bin/make-deb.sh "$(SRC)"
```

In the `rpm` command in the `Makefile`, the following command runs a container
to build a `.rpm` package:

```
@docker run --rm -it \
  -e RPMFULLNAME="$(MAINTAINER_NAME)" \
  -e RPMEMAIL="$(MAINTAINER_EMAIL)" \
  -v $(PWD)/build:/host \
  extremais/pkg-fedora-stack:34 \
  /home/docker/bin/make-rpm.sh "$(SRC)"
```

[hr]: <https://github.com/ExtremaIS/hr-haskell#hr>

## Project

### Contribution

Issues are tracked on GitHub:
<https://github.com/ExtremaIS/docker-pkg/issues>

Issues may also be submitted via email to <bugs@extrema.is>.

### License

This project is released under the
[MIT License](https://opensource.org/licenses/MIT) as specified in the
[`LICENSE`](LICENSE) file.
