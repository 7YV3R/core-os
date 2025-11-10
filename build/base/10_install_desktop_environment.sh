#!/usr/bin/env bash

set -euox pipefail


# This parent script installs desktop environments
# Disable or enable other desktop environments via
# (un)commenting of the build script.

# Install KDE
/build/11_install_kde.sh

# Install Hyprland
/build/12_install_hyprland.sh

# start directly into installed desktop environment
systemctl set-default graphical.target

# cleanup layer
/scripts/99_cleanup_layer.sh