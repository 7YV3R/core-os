#!/usr/bin/env bash

set -ouex pipefail

### Install Asus related stuff

# install modules file
mkdir -p /usr/lib/modules-load.d/
cp /ctx/system_files/surface/surface.conf /usr/lib/modules-load.d/

# install iptsd config
mkdir -p /etc/iptsd.d
cp /ctx/system_files/surface/90-calibration.conf /etc/iptsd.d/

# install prepared repo files
mkdir -p /etc/yum.repos.d
cp /ctx/repo_files/linux-surface.repo /etc/yum.repos.d/

# ensure Repo is temporarily enabled
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/linux-surface.repo

# create a shims to bypass kernel install triggering dracut/rpm-ostree
# seems to be minimal impact, but allows progress on build
cd /usr/lib/kernel/install.d \
&& mv 05-rpmostree.install 05-rpmostree.install.bak \
&& mv 50-dracut.install 50-dracut.install.bak \
&& printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install \
&& printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install \
&& chmod +x  05-rpmostree.install 50-dracut.install

# Get current Kernel version
OLD_KERNEL_VERSION="$(rpm -q --queryformat="%{evr}.%{arch}" kernel-core)"

# install surface kernel
dnf5 download --destdir="/tmp" \
    kernel-surface \
    kernel-surface-devel \
    kernel-surface-modules \
    kernel-surface-modules-extra

# replace kernel
rpm-ostree override replace \
    /tmp/kernel-surface*

# replace touch libraries
dnf5 -y swap \
    libwacom-data libwacom-surface-data
dnf5 -y swap \
    libwacom libwacom-surface


# ensure Repo is disabled
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/linux-surface.repo

# create initramfs
export DRACUT_NO_XATTR=1
NEW_KERNEL_VERSION="$(rpm -q --queryformat="%{evr}.%{arch}" kernel-surface-core)"
dracut --no-hostonly --kver "${NEW_KERNEL_VERSION}" --reproducible -v --add ostree -f "/lib/modules/${NEW_KERNEL_VERSION}/initramfs.img"
chmod 0600 "/lib/modules/${NEW_KERNEL_VERSION}/initramfs.img"


# restore kernel install
cd /usr/lib/kernel/install.d && \
mv -f 05-rpmostree.install.bak 05-rpmostree.install \
&& mv -f 50-dracut.install.bak 50-dracut.install
cd -

# Cleanup
dnf5 clean all
rm -rf /usr/lib/modules/${OLD_KERNEL_VERSION}
rm -rf /boot/* && rm -rf /boot/.*
rm -rf /tmp/* && rm -rf /tmp/.*
rm -rf /var/cache/dnf