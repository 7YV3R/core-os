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
	gparted \
	htop \
	iotop \
	ksshaskpass \
    librewolf \
	lm_sensors \
	nano \
	ncdu \
	NetworkManager-wifi \
	osbuild-selinux \
	p7zip \
	plymouth \
	plymouth-plugin-script \
	screen \
	syncthing \
	thermald \
	tuned \
	wireshark

# install wifi firmware
dnf5 install --best --allowerasing -y --skip-unavailable \
	atheros-firmware \
	atmel-firmware \
	b43-fwcutter \
	b43-openfwwf \
	brcmfmac-firmware \
	iwlegacy-firmware \
	iwlwifi-dvm-firmware \
	iwlwifi-mvm-firmware \
	libertas-firmware \
	mt7xxx-firmware \
	nxpwireless-firmware \
	realtek-firmware \
	tiwilink-firmware \
	zd1211-firmware

# Setup plymouth theme
plymouth-set-default-theme square_hud -R

# install veracrypt
VERACRYPT_DOWNLOAD_URL="https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-1.26.24-Fedora-40-x86_64.rpm"
rpm -i ${VERACRYPT_DOWNLOAD_URL}

# remove unwanted packages
dnf5 remove -y --no-autoremove \
	dnf-data \
	dracut-config-rescue \
    firefox \
    firefox-es \
	PackageKit-command-not-found \
	plasma-discover-offline-updates \
	plasma-discover-packagekit \
	plasma-pk-updates \
	rsyslog \
	tracker \
	tracker-miners \
	plasma-x11 \
	plasma-workspace-x11

# enable services
systemctl enable cockpit.socket
systemctl enable fstrim.timer
systemctl enable lm_sensors
systemctl enable tuned

# ensure Repo is disabled
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/librewolf.repo
