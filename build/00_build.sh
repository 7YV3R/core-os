#!/usr/bin/env bash

set -euox pipefail

# Prepare base
/ctx/build/01_prepare_base.sh

# get the newest installed kernel version and make variable useable in subscripts
export kver=$(rpm -q kernel | sort -V | head -n 1 | cut -d' ' -f1 | sed 's/^kernel-//')

# Install KDE
/ctx/build/10_install_kde.sh

# Install core software components and remove unwanted one
/ctx/build/20_setup_base_software.sh

if [ "${INSTALL_NVIDIA}" == "true" ]; then
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