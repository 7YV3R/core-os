#!/usr/bin/env bash
set -euox pipefail

# create root home
mkdir -p /var/roothome
mkdir -p /var/opt
ln -s /opt /var/opt
mkdir -p /usr/lib/sysusers.d
mkdir -p /var/lib/overlay-wsessions/{upper,work}

# Install new dnf5 implementation if not available
# all following manipulations need dnf5
dnf install -y dnf5 dnf5-plugins

# install fake uname
/scripts/10_uname_installer.sh install

# get the newest installed kernel version and make variable useable in subscripts
export kver="$(/scripts/10_get_kernel_version.sh)"

# install plymouth
dnf5 install --best --allowerasing -y --skip-unavailable \
	plymouth \
	plymouth-plugin-script

# Setup plymouth theme
plymouth-set-default-theme unrap

# rebuild initramfs
/scripts/10_build_initramfs.sh

# set SELinux to permissive mode
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# enable bootloader updater
systemctl enable bootloader-update.service
# enable overlayfs for wayland-sessions
systemctl enable usr-share-wayland\\x2dsessions.mount

# disable hibernation and sleep
systemctl mask sleep.target 
systemctl mask suspend.target 
systemctl mask hibernate.target 
systemctl mask hybrid-sleep.target

# disable Avahi Daemon
systemctl disable avahi-daemon

# disable bluetooth at start
systemctl disable bluetooth.service

# disable bootc-fetch-apply-updates.timer
systemctl disable bootc-fetch-apply-updates.timer

# create cryptographics
/scripts/10_create_cryptographics.sh

# uninstall fake uname
/scripts/10_uname_installer.sh uninstall

# cleanup layer
/scripts/99_cleanup_layer.sh