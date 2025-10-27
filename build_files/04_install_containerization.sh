#!/usr/bin/env bash

set -ouex pipefail

### Install Docker environment

# install prepared repo files
mkdir -p /etc/yum.repos.d
cp /ctx/repo_files/docker-ce.repo /etc/yum.repos.d/

# ensure Repo is temporarily enabled
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/docker-ce.repo

# generate docker group
groupadd -f -g 952 docker

# install dev tools packages
dnf5 install -y --setopt=install_weak_deps=False \
	containerd.io \
	distrobox \
	docker-buildx-plugin \
	docker-ce \
	docker-ce-cli \
	docker-compose-plugin \
	podman-machine \
	podman-tui \
	podmansh \
	toolbox \
	xhost


# set docker backend for distrobox
mkdir -p /etc/distrobox
cp /ctx/system_files/shared/distrobox.conf /etc/distrobox/

# ip-tables fix for root podman to access network
# sudo iptables -P FORWARD ACCEPT
mkdir -p /etc/modules-load.d
cp /ctx/system_files/shared/ip_tables.conf /etc/modules-load.d/


# install fix for gui applications in distrobox
mkdir -p /etc/skel
echo "xhost +si:localuser:\$USER >/dev/null" > /etc/skel/.distroboxrc
# for the current user:
# echo "xhost +si:localuser:$USER >/dev/null" > ~/.distroboxrc

# ensure Repo is disabled
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/docker-ce.repo

# enable docker service
systemctl enable docker

# Cleanup
dnf5 clean all
rm -rf /var/cache/dnf