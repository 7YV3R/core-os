#!/usr/bin/env bash

set -ouex pipefail

### Install Asus related stuff

# enable Asus Linux copr
dnf5 -y copr enable lukenukem/asus-linux
dnf5 -y copr enable jhyub/supergfxctl-plasmoid

# install Asus packages
dnf5 install -y --setopt=install_weak_deps=False \
    asusctl \
    supergfxctl \
    supergfxctl-plasmoid


# disable the copr for building the image
dnf5 -y copr disable lukenukem/asus-linux
dnf5 -y copr disable jhyub/supergfxctl-plasmoid

# Enable the supergfd service on boot
systemctl enable supergfxd.service

# Cleanup
dnf5 clean all
rm -rf /var/cache/dnf