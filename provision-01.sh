#!/usr/bin/env bash

# should be run as root

set -x

apt-get update

# should already have: wget, curl

# basic apps

DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    apt-transport-https     \
    aptitude                \
    bash                    \
    bash-completion         \
    bzip2                   \
    ca-certificates         \
    command-not-found       \
    expect                  \
    file                    \
    fakeroot                \
    gpg                     \
    jq                      \
    less                    \
    lsof                    \
    lynx                    \
    netcat-openbsd          \
    procps                  \
    pv                      \
    openssh-client          \
    screen                  \
    sudo                    \
    time

# extra utils

DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    binutils                \
    bsdmainutils            \
    coreutils               \
    diffutils               \
    findutils               \
    moreutils               \
    patchutils              \
    sharutils

