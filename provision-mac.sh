#!/usr/bin/env bash

# should be run as root

set -x
set -euo pipefail

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

# dev tools

DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    afl++-clang             \
    build-essential         \
    clang                   \
    clang-format            \
    clang-tidy              \
    clang-tools             \
    g++-multilib            \
    gdb                     \
    git                     \
    gpg                     \
    indent                  \
    libtool                 \
    llvm-10-dev             \
    pkg-config              \
    splint                  \
    universal-ctags         \
    valgrind                \
    xxd                     \
    zzuf

# docco

DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    man-db                  \
    manpages                \
    manpages-dev            \
    manpages-posix          \
    manpages-posix-dev



