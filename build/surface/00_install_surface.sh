#!/usr/bin/env bash

set -ouex pipefail

# get the newest installed kernel version and make variable useable in subscripts
export kver="$(/scripts/10_get_kernel_version.sh)"

# install fake uname
/scripts/10_uname_installer.sh install

# install kernel-installer-fix
/surface/10_kernel_installer_fix.sh install

# fix because there is no f43 release version at the moment
if [ "${BASE_IMAGE_TAG}" == "43" ]; then
    RELEASE_VERSION="42"
else
    RELEASE_VERSION="${BASE_IMAGE_TAG}"
fi
sed -i "s|baseurl=https://pkg.surfacelinux.com/fedora/f\$releasever/|baseurl=https://pkg.surfacelinux.com/fedora/f${RELEASE_VERSION}/|" /etc/yum.repos.d/linux-surface.repo


# ensure Repo is temporarily enabled
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/linux-surface.repo

# remove original kernel
dnf5 -y remove kernel*

# install surface kernel
dnf5 -y install --allowerasing kernel-surface iptsd libwacom-surface

# ensure Repo is disabled
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/linux-surface.repo

# get the newest installed surface kernel version
export kver="$(/surface/10_get_surface_kernel_version.sh)"

# rebuild initramfs
/scripts/10_build_initramfs.sh

# cleanup layer
/scripts/99_cleanup_layer.sh