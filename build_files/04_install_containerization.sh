#!/usr/bin/env bash

set -ouex pipefail

### Install containerization environment

# install prepared repo files
mkdir -p /etc/yum.repos.d
cp /ctx/repo_files/docker-ce.repo /etc/yum.repos.d/

# ensure Repo is temporarily enabled
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/docker-ce.repo

# Apply IP Forwarding before installing Docker to prevent messing with LXC networking
sysctl -p

# Load iptable_nat module for docker-in-docker.
# See:
#   - https://github.com/ublue-os/bluefin/issues/2365
#   - https://github.com/devcontainers/features/issues/1235
mkdir -p /etc/modules-load.d
cp /ctx/system_files/shared/modules/ip_tables.conf /etc/modules-load.d/ip_tables.conf

# Activate IP forwarding
mkdir -p /etc/sysctl.d
cp /ctx/system_files/shared/sysctl/docker-ce.conf /etc/sysctl.d/

# install Podman NAT fix
mkdir -p /etc/systemd/system
cp /ctx/system_files/shared/systemd/podmanfix.service /etc/systemd/system/

# create group for docker socket access
groupadd -f -g 952 docker

# install docker packages
dnf5 install -y --setopt=install_weak_deps=False \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin

# install podman and additional containerization packages
dnf5 install -y --setopt=install_weak_deps=False \
	distrobox \
	podman-machine \
	podman-tui \
	podmansh \
	toolbox \
	xhost

# install fix for gui applications in distrobox
mkdir -p /etc/skel
echo "xhost +si:localuser:\$USER >/dev/null" > /etc/skel/.distroboxrc
# for the current user:
# echo "xhost +si:localuser:$USER >/dev/null" > ~/.distroboxrc

# ensure Repo is disabled
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/docker-ce.repo

# enable services
systemctl enable docker
systemctl enable podmanfix

# Cleanup
dnf5 clean all
rm -rf /var/cache/dnf