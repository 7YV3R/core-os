#!/usr/bin/env bash

set -ouex pipefail

### Install Docker environment

# install prepared repo files
#mkdir -p /etc/yum.repos.d
#cp /ctx/repo_files/docker-ce.repo /etc/yum.repos.d/

# ensure Repo is temporarily enabled
#sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/docker-ce.repo

# install dev tools packages
dnf5 install -y --setopt=install_weak_deps=False \
	distrobox \
	podman-compose \
	podman-docker \
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
#sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/docker-ce.repo

# Cleanup
dnf5 clean all
rm -rf /var/cache/dnf