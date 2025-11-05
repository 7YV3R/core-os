#!/usr/bin/env bash

set -euox pipefail

# enable Asus Linux copr
dnf5 copr enable -y lukenukem/asus-linux
dnf5 copr enable -y jhyub/supergfxctl-plasmoid

# install Asus packages
dnf5 install -y --setopt=install_weak_deps=False \
    asusctl \
    supergfxctl \
    supergfxctl-plasmoid

# disable the copr for building the image
dnf5 copr disable -y lukenukem/asus-linux
dnf5 copr disable -y jhyub/supergfxctl-plasmoid

# Enable the supergfd service on boot
systemctl enable supergfxd.service

# perform cleanup
/scripts/99_cleanup_layer.sh