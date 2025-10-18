#!/usr/bin/env bash

set -ouex pipefail

### Install Asus related stuff

# install prepared repo files
mkdir -p /etc/yum.repos.d
cp /ctx/repo_files/linux-surface.repo /etc/yum.repos.d/

# ensure Repo is temporarily enabled
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/linux-surface.repo

# install Surface packages
dnf5 install -y --setopt=install_weak_deps=False \
    iptsd \
    libcamera \
    libcamera-tools \
    libcamera-gstreamer \
    libcamera-ipa \
    pipewire-plugin-libcamera

dnf5 -y swap \
    libwacom-data libwacom-surface-data

dnf5 -y swap \
    libwacom libwacom-surface

# ensure Repo is disabled
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/linux-surface.repo


# install modules file
cp /ctx/system_files/surface.conf /usr/lib/modules-load.d/surface.conf 

# Cleanup
dnf5 clean all
rm -rf /var/cache/dnf