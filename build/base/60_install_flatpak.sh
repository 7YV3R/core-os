#!/usr/bin/env bash

set -euox pipefail

# install flathub repository
flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Attention: these Flatpak applications will only be installed during the
# initial installation process. So modifying this list AFTER
# the initial installation by updating the image, will NOT add the
# Flathub applications to the system.
#
# This method currently generates a lot of Linting Warnings, because it
# manipulates the /var/lib folder and it will NOT be touched AFTER the
# initial installation process.
# We have to wait, till flathub finally integrates the command "preinstall".
# FIX this
flatpak install -y --system \
    eu.betterbird.Betterbird \
	com.brave.Browser \
    org.gimp.GIMP \
    org.libreoffice.LibreOffice \
    com.github.dynobo.normcap \
    org.videolan.VLC

# cleanup layer
/scripts/99_cleanup_layer.sh