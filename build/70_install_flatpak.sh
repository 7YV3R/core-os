#!/usr/bin/env bash

set -euox pipefail

flatpak remotes

# install flathub repository
flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# remove Fedoras flatpak hub
#flatpak remote-delete --system fedora


# install a selection of flatpak images
flatpak install --system -y \
    com.brave.Browser \
    org.chromium.Chromium \
    com.ranfdev.DistroShelf \
    org.gimp.GIMP \
    org.libreoffice.LibreOffice \
    com.github.dynobo.normcap \
    io.podman_desktop.PodmanDesktop \
    org.videolan.VLC