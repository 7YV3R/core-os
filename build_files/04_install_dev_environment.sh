#!/usr/bin/env bash

set -ouex pipefail

### Install custom development environment

# install prepared repo files
mkdir -p /etc/yum.repos.d
cp /ctx/repo_files/vscodium.repo /etc/yum.repos.d/

# ensure Repo is temporarily enabled
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/vscodium.repo

# install dev tools packages
dnf5 install -y \
	android-tools \
	codium \
	git \
	python3 \
	python3-pip \
	python3-virtualenv


# ensure Repo is disabled
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/vscodium.repo