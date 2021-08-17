##############################################################################
# Project configuration

##############################################################################
# Make configuration

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error GNU Make 4.0 or later required)
endif
.RECIPEPREFIX := >

SHELL := bash
.SHELLFLAGS := -o nounset -o errexit -o pipefail -c

MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables

.DEFAULT_GOAL := help

##############################################################################
# Rules

build-debian: #internal# build Debian image
> docker build \
>   --build-arg "TERM=${TERM}" \
>   --build-arg "USER_GID=$(shell id -g)" \
>   --build-arg "USER_UID=$(shell id -u)" \
>   --file debian/$(DOCKER_TAG)/Dockerfile \
>   --tag extremais/pkg-debian:$(DOCKER_TAG) \
>   .
.PHONY: build-debian

build-debian-stack: #internal# build Debian Stack image
> docker build \
>   --file debian-stack/$(DOCKER_TAG)/Dockerfile \
>   --tag extremais/pkg-debian-stack:$(DOCKER_TAG) \
>   .
.PHONY: build-debian-stack

build-fedora: #internal# build Fedora image
> docker build \
>   --build-arg "TERM=${TERM}" \
>   --build-arg "USER_GID=$(shell id -g)" \
>   --build-arg "USER_UID=$(shell id -u)" \
>   --file fedora/$(DOCKER_TAG)/Dockerfile \
>   --tag extremais/pkg-fedora:$(DOCKER_TAG) \
>   .
.PHONY: build-fedora

build-fedora-stack: #internal# build Fedora Stack image
> docker build \
>   --file fedora-stack/$(DOCKER_TAG)/Dockerfile \
>   --tag extremais/pkg-fedora-stack:$(DOCKER_TAG) \
>   .
.PHONY: build-fedora-stack

help: # show this help
> @grep '^[a-zA-Z0-9._-]\+:[^#]*# ' $(MAKEFILE_LIST) \
>   | sed 's/^\([^:]\+\):[^#]*# \(.*\)/make \1\t\2/' \
>   | column -t -s $$'\t'
.PHONY: help

list: # list built/tagged images
> @docker images "extremais/pkg-*"
.PHONY: list

pkg-debian-buster: # build extremais/pkg-debian:buster
pkg-debian-buster: DOCKER_TAG = buster
pkg-debian-buster: build-debian
.PHONY: pkg-debian-buster

pkg-debian-stack-buster: # build extremais/pkg-debian-stack:buster
pkg-debian-stack-buster: DOCKER_TAG = buster
pkg-debian-stack-buster: build-debian-stack
.PHONY: pkg-debian-stack-buster

pkg-fedora-34: # build extremais/pkg-fedora:34
pkg-fedora-34: DOCKER_TAG = 34
pkg-fedora-34: build-fedora
.PHONY: pkg-fedora-34

pkg-fedora-stack-34: # build extremais/pkg-fedora-stack:34
pkg-fedora-stack-34: DOCKER_TAG = 34
pkg-fedora-stack-34: build-fedora-stack
.PHONY: pkg-fedora-stack-34

shellcheck: # run shellcheck on scripts
> @find . -name '*.sh' | xargs shellcheck
.PHONY: shellcheck
