#!/usr/bin/env bash

set -ouex pipefail

### Install extended system components

# Install dnf5 if not installed
if ! rpm -q dnf5 >/dev/null; then
    rpm-ostree install dnf5 dnf5-plugins
fi

# install extended system packages
dnf5 install -y \
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
rpm -i https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-1.26.24-Fedora-40-x86_64.rpm

# install scrcpy
dnf5 copr enable zeno/scrcpy -y
dnf5 install -y scrcpy
dnf5 copr disable zeno/scrcpy -y

# ensure flathub repo is available
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# enable services
systemctl enable cockpit.socket

# set SELinux to permissive mode
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# disable hibernation and sleep
systemctl mask sleep.target 
systemctl mask suspend.target 
systemctl mask hibernate.target 
systemctl mask hybrid-sleep.target
