#!/usr/bin/env bash

# should be run as root

set -x

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

