#!/usr/bin/env bash

set -ouex pipefail

### Install Asus related stuff

# enable Asus Linux copr
dnf5 -y copr enable lukenukem/asus-linux

# install Asus packages
dnf5 install -y \
    asusctl \
    supergfxctl


# disable the copr for building the image
dnf5 -y copr disable lukenukem/asus-linux

# Enable the supergfd service on boot
systemctl enable supergfxd.service

