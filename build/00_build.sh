#!/usr/bin/env bash

set -euox pipefail

# get the newest installed kernel version and make variable useable in subscripts
export kver="$(/scripts/get_kernel_version.sh)"

# Prepare base
/ctx/build/01_prepare_base.sh

# Install KDE
/ctx/build/10_install_kde.sh

# Install Hyprland
#/ctx/build/11_install_hyprland.sh

# Install core software components and remove unwanted one
/ctx/build/20_setup_base_software.sh

if [ "${INSTALL_NVIDIA}" == "true" ] && [ "${INSTALL_SURFACE}" != "true" ]; then
  # Install NVIDIA
  /ctx/build/30_install_nvidia.sh
fi

# install containerization stuff
/ctx/build/40_install_containerization.sh

# install virtualization stuff
/ctx/build/50_install_virtualization.sh

# install development environment
/ctx/build/60_install_dev_env.sh

# install Flatpak system wide
/ctx/build/70_install_flatpak.sh

# perform cleanup
/ctx/build/99_cleanup.sh