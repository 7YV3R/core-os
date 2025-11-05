#!/usr/bin/env bash
set -euox pipefail

# get the newest installed kernel version and make variable useable in subscripts
export kver="$(/scripts/10_get_kernel_version.sh)"

# install fake uname
/scripts/10_uname_installer.sh install

# ensure Repo is enabled
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/cuda-fedora.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/nvidia-container-toolkit.repo

# install RPM-Fusion Repos
dnf5 -y install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# install nvidia drivers
dnf5 install -y --skip-unavailable --best --allowerasing -y \
  akmod-nvidia \
  xorg-x11-drv-nvidia-cuda

# use the freeworld drivers
dnf5 swap -y mesa-va-drivers mesa-va-drivers-freeworld
dnf5 swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

# ensure Repo is disabled
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/cuda-fedora.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/nvidia-container-toolkit.repo

# workaround for akmod permission issue
chmod 777 /var/tmp

# perform building kernel modules
# PATH=/tmp/bin:$PATH dkms autoinstall -k ${kver}
akmods --force --kernels ${kver}

# rebuild initramfs
/scripts/10_build_initramfs.sh

# revert permissions
chmod 755 /var/tmp

# cleanup layer
/scripts/99_cleanup_layer.sh