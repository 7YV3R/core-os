#!/usr/bin/env bash

set -euox pipefail

# install librewolf as temporary repo
# to be able to install librewolf
cat <<EOF > "/etc/yum.repos.d/librewolf.repo"
[repository]
name=LibreWolf Software Repository
baseurl=https://repo.librewolf.net
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://repo.librewolf.net/pubkey.gpg
EOF

# install basic additional software
dnf5 install --best --allowerasing -y --skip-unavailable --nodocs --setopt=install_weak_deps=False \
	bolt \
	btop \
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

# disable services
systemctl disable bolt # fixes some weird issues with charging

# remove temporary repos, so that they are not part of the image
rm -rf /etc/yum.repos.d/librewolf.repo

# cleanup layer
/scripts/99_cleanup_layer.sh