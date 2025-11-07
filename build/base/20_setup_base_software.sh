#!/usr/bin/env bash

set -euox pipefail

# ensure Repo is disabled
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/librewolf.repo

# install basic additional software
dnf5 install --best --allowerasing -y --skip-unavailable \
	bolt \
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
	fastfetch \
	fzf \
	gparted \
	htop \
	iotop \
	jq \
    librewolf \
	lm_sensors \
	nano \
	ncdu \
	osbuild-selinux \
	p7zip \
	screen \
	syncthing \
	thermald \
	tuned \
	wireshark \
	wget \
	wxGTK3

# remove unwanted packages
dnf5 remove -y --no-autoremove \
	dnf-data \
	dracut-config-rescue \
    firefox \
    firefox-es \
	PackageKit-command-not-found \
	rsyslog \
	tracker \
	tracker-miners

# enable services
systemctl enable cockpit.socket
systemctl enable fstrim.timer
systemctl enable lm_sensors
systemctl enable tuned

# ensure Repo is disabled
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/librewolf.repo

# cleanup layer
/scripts/99_cleanup_layer.sh