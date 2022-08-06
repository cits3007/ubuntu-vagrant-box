#!/usr/bin/env bash

# should be run as root

set -x
set -euo pipefail

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

# configure network

# would be nice to disable systemd-resolved altogether..
# see https://askubuntu.com/questions/1333643/how-to-disable-127-0-0-53-as-dns

echo "Create netplan config for eth0"
cat <<EOF >/etc/netplan/01-netcfg.yaml;
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
EOF

update-grub

# DNS config fails under wifi
echo "disable pointless resolved.conf lines"
sed  -i 's/^DNS/#&/; s/^Cache/#&/;' /etc/systemd/resolved.conf

systemctl daemon-reload
systemctl restart systemd-resolved


