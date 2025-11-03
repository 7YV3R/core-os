#!/usr/bin/env bash
set -euox pipefail

# ensure Repo is enabled
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/cuda-fedora.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/nvidia-container-toolkit.repo

# install kargs
echo "kargs = [\"nvidia-drm.modeset=1 nouveau.modeset=0 rd.driver.blacklist=nouveau,nova-core modprobe.blacklist=nouveau,nova-core\"]" > /usr/lib/bootc/kargs.d/10-nvidia.toml

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
PATH=/tmp/bin:$PATH akmods --force --kernels ${kver}

# revert permissions
chmod 755 /var/tmp