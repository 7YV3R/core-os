#!/usr/bin/env bash

set -euox pipefail

# ensure Repo is temporarily enabled
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/vscodium.repo

# install dev tools packages
dnf5 install -y --setopt=install_weak_deps=False \
	android-tools \
	codium \
	git

# ensure Repo is disabled
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/vscodium.repo
