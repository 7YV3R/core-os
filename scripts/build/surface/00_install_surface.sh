#!/usr/bin/env bash

set -ouex pipefail

# install fake uname
/scripts/10_uname_installer.sh install

# install kernel-installer-fix
/surface/10_kernel_installer_fix.sh install

# get the newest installed kernel version and make variable useable in subscripts
export kver="$(/scripts/10_get_kernel_version.sh)"

# fix because there is no f43 release version at the moment
if [ "${BASE_IMAGE_TAG}" == "43" ]; then
    RELEASE_VERSION="42"
else
    RELEASE_VERSION="${BASE_IMAGE_TAG}"
fi

# install linux surface as temporary repo
# to be able to install kernel and modules for linux on surface devices
cat <<EOF > "/etc/yum.repos.d/linux-surface.repo"
[linux-surface]
name=linux-surface
baseurl=https://pkg.surfacelinux.com/fedora/f$RELEASE_VERSION/
enabled=1
skip_if_unavailable=1
gpgkey=https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc
gpgcheck=1
enabled_metadata=1
type=rpm-md
repo_gpgcheck=0
EOF

# remove original kernel
dnf5 -y remove kernel*

# install surface kernel
dnf5 -y install --allowerasing kernel-surface iptsd libwacom-surface

# remove temporary repos, so that they are not part of the image
rm -rf /etc/yum.repos.d/linux-surface.repo


# get the newest installed surface kernel version
export kver="$(/surface/10_get_surface_kernel_version.sh)"

# rebuild initramfs
/scripts/10_build_initramfs.sh

# uninstall kernel-installer-fix
/surface/10_kernel_installer_fix.sh uninstall

# uninstall fake uname
/scripts/10_uname_installer.sh uninstall

# cleanup layer
/scripts/99_cleanup_layer.sh