#!/usr/bin/env bash

set -ouex pipefail

### Install extended system components

VERACRYPT_DOWNLOAD_URL="https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-1.26.24-Fedora-40-x86_64.rpm"

# Install dnf5 if not installed
if ! rpm -q dnf5 >/dev/null; then
    rpm-ostree install dnf5 dnf5-plugins
fi

# install extended system packages
dnf5 install -y --setopt=install_weak_deps=False \
	bolt \
	chromium \
	cockpit-bridge \
	cockpit-files \
	cockpit-machines \
	cockpit-networkmanager \
	cockpit-ostree \
	cockpit-podman \
	cockpit-selinux \
	cockpit-storaged \
	cockpit-system \
	cockpit-ws \
	cockpit-ws-selinux \
	dkms \
	gparted \
	iotop \
	keepassxc \
	ksshaskpass \
	lm_sensors \
	ncdu \
	openldap \
	osbuild-selinux \
	p7zip \
	screen \
	syncthing \
	thermald \
	tuned \
	wireshark

# remove packages
dnf5 remove -y \
    firefox \
    firefox-es \
	plasma-discover-offline-updates \
	plasma-discover-packagekit \
	plasma-pk-updates \
	tracker \
	tracker-miners \
	plasma-x11 \
	plasma-workspace-x11

# install veracrypt
rpm -i ${VERACRYPT_DOWNLOAD_URL}

# install scrcpy
dnf5 copr enable zeno/scrcpy -y
dnf5 install -y --setopt=install_weak_deps=False \
	scrcpy
dnf5 copr disable zeno/scrcpy -y

# enable services
systemctl enable cockpit.socket

# set SELinux to permissive mode
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# disable hibernation and sleep
systemctl mask sleep.target 
systemctl mask suspend.target 
systemctl mask hibernate.target 
systemctl mask hybrid-sleep.target

# disable bluetooth at start
systemctl disable bluetooth.service

# Cleanup
dnf5 clean all
rm -rf /var/cache/dnf