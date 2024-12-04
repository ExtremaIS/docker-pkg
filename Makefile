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
# Functions

define all_files
  find . -not -path '*/\.*' -type f
endef

define die
  (echo "error: $(1)" ; false)
endef

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

grep: # grep all non-hidden files for expression E
> $(eval E:= "")
> @test -n "$(E)" || $(call die,"usage: make grep E=expression")
> @$(call all_files) | xargs grep -Hn '$(E)' || true
.PHONY: grep

help: # show this help
> @grep '^[a-zA-Z0-9._-]\+:[^#]*# ' $(MAKEFILE_LIST) \
>   | sed 's/^\([^:]\+\):[^#]*# \(.*\)/make \1\t\2/' \
>   | column -t -s $$'\t'
.PHONY: help

ignored: # list files ignored by git
> @git ls-files . --ignored --exclude-standard --others
.PHONY: ignored

list: # list built/tagged images
> @docker images "extremais/pkg-*"
.PHONY: list

pkg-debian-bookworm: # build extremais/pkg-debian:bookworm
pkg-debian-bookworm: DOCKER_TAG = bookworm
pkg-debian-bookworm: build-debian
.PHONY: pkg-debian-bookworm

pkg-debian-stack-bookworm: # build extremais/pkg-debian-stack:bookworm
pkg-debian-stack-bookworm: DOCKER_TAG = bookworm
pkg-debian-stack-bookworm: build-debian-stack
.PHONY: pkg-debian-stack-bookworm

pkg-debian-buster: # build extremais/pkg-debian:buster
pkg-debian-buster: DOCKER_TAG = buster
pkg-debian-buster: build-debian
.PHONY: pkg-debian-buster

pkg-debian-stack-buster: # build extremais/pkg-debian-stack:buster
pkg-debian-stack-buster: DOCKER_TAG = buster
pkg-debian-stack-buster: build-debian-stack
.PHONY: pkg-debian-stack-buster

pkg-debian-bullseye: # build extremais/pkg-debian:bullseye
pkg-debian-bullseye: DOCKER_TAG = bullseye
pkg-debian-bullseye: build-debian
.PHONY: pkg-debian-bullseye

pkg-debian-stack-bullseye: # build extremais/pkg-debian-stack:bullseye
pkg-debian-stack-bullseye: DOCKER_TAG = bullseye
pkg-debian-stack-bullseye: build-debian-stack
.PHONY: pkg-debian-stack-bullseye

pkg-fedora-41: # build extremais/pkg-fedora:41
pkg-fedora-41: DOCKER_TAG = 41
pkg-fedora-41: build-fedora
.PHONY: pkg-fedora-41

pkg-fedora-stack-41: # build extremais/pkg-fedora-stack:41
pkg-fedora-stack-41: DOCKER_TAG = 41
pkg-fedora-stack-41: build-fedora-stack
.PHONY: pkg-fedora-stack-41

recent: # show N most recently modified files
> $(eval N := "10")
> @find . -not -path '*/\.*' -type f -printf '%T+ %p\n' \
>   | sort --reverse \
>   | head -n $(N)
.PHONY: recent

shellcheck: # run shellcheck on scripts
> @find . -name '*.sh' | xargs shellcheck
.PHONY: shellcheck

todo: # search for TODO items
> @find . -type f \
>   -not -path '*/\.*' \
>   -not -path './build/*' \
>   -not -path './project/*' \
>   -not -path ./Makefile \
>   | xargs grep -Hn TODO \
>   | grep -v '^Binary file ' \
>   || true
.PHONY: todo
