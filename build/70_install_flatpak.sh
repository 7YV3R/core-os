#!/usr/bin/env bash

set -euox pipefail

# install flathub repository
flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# enable services
systemctl enable flatpack-preinstall.service
