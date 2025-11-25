#!/usr/bin/env bash
set -euox pipefail

# install fake uname
/scripts/10_uname_installer.sh install

# get the newest installed kernel version and make variable useable in subscripts
export kver="$(/scripts/10_get_kernel_version.sh)"

# fix because there is no f43 release version at the moment
if [ "${BASE_IMAGE_TAG}" == "43" ]; then
    RELEASE_VERSION="42"
else
    RELEASE_VERSION="${BASE_IMAGE_TAG}"
fi

# install nvidia cuda as temporary repo
# to be able to install cuda
cat <<EOF > "/etc/yum.repos.d/cuda-fedora.repo"
[cuda-fedora-x86_64]
name=cuda-fedora-x86_64
baseurl=https://developer.download.nvidia.com/compute/cuda/repos/fedora$RELEASE_VERSION/x86_64
enabled=1
exclude=nvidia-driver,nvidia-modprobe,nvidia-persistenced,nvidia-settings,nvidia-libXNVCtrl,nvidia-xconfig
gpgcheck=1
gpgkey=https://developer.download.nvidia.com/compute/cuda/repos/fedora$RELEASE_VERSION/x86_64/D42D0685.pub
EOF

# install nvidia container toolkit repo as temporary repo
# to be able to install nvidia container toolkit
cat <<EOF > "/etc/yum.repos.d/nvidia-container-toolkit.repo"
[nvidia-container-toolkit]
name=nvidia-container-toolkit
baseurl=https://nvidia.github.io/libnvidia-container/stable/rpm/\$basearch
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://nvidia.github.io/libnvidia-container/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

# install RPM-Fusion Repos
dnf5 -y install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# install nvidia drivers
dnf5 install -y --skip-unavailable --best --allowerasing --nodocs --setopt=install_weak_deps=False \
  akmod-nvidia \
  xorg-x11-drv-nvidia-cuda

# use the freeworld drivers
dnf5 swap -y mesa-va-drivers mesa-va-drivers-freeworld
dnf5 swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

# workaround for akmod permission issue
chmod 777 /var/tmp

# perform building kernel modules
# PATH=/tmp/bin:$PATH dkms autoinstall -k ${kver}
akmods --force --kernels ${kver}

# rebuild initramfs
/scripts/10_build_initramfs.sh

# revert permissions
chmod 755 /var/tmp

# ensure Repo files are deleted from image
rm -rf /etc/yum.repos.d/cuda-fedora.repo
rm -rf /etc/yum.repos.d/nvidia-container-toolkit.repo
rm -rf /etc/yum.repos.d/rpmfusion*

# uninstall fake uname
/scripts/10_uname_installer.sh uninstall

# cleanup layer
/scripts/99_cleanup_layer.sh