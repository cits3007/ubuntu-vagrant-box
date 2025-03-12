#!/usr/bin/env bash

# Add CITS3007 development packages for UTM-based guests.
# The code should work regardless of whether our guest uses Debian or
# Ubuntu.

# Should be run as root.
# Assumes that wget and curl are already installed (plus any
# of their essential dependencies such as ca-certificates).

set -x
set -euo pipefail


# If on a debian-based host: ensure non-free components are enabled.

. /etc/os-release

if [[ "$ID" == "debian" ]]; then
  cname="$VERSION_CODENAME"
  sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb http://deb.debian.org/debian/ ${cname} main non-free non-free-firmware
deb-src http://deb.debian.org/debian/ ${cname} main non-free non-free-firmware

deb http://security.debian.org/debian-security ${cname}-security main non-free non-free-firmware
deb-src http://security.debian.org/debian-security ${cname}-security main non-free non-free-firmware

deb http://deb.debian.org/debian/ ${cname}-updates main non-free non-free-firmware
deb-src http://deb.debian.org/debian/ ${cname}-updates main non-free non-free-firmware
EOF

  echo "Updated /etc/apt/sources.list for Debian."
fi

apt-get update


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

# possibly missing from UTM base images, but common for vagrant boxes

DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    hdparm                  \
    kpartx                  \
    lshw                    \
    parted                  \
    unzip                   \
    usbutils                \
    vim                     \
    xz-utils                \
    zip

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
    afl++                      \
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
    llvm-dev                \
    pkg-config              \
    splint                  \
    universal-ctags         \
    valgrind                \
    xxd

# docco

# Note that manpages-posix-* are in the "non-free" section on Debian.

DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    man-db                  \
    manpages                \
    manpages-dev            \
    manpages-posix          \
    manpages-posix-dev



