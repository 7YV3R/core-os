#!/usr/bin/env bash

set -euox pipefail

# install vscodium repo
cat <<EOF > "/etc/yum.repos.d/vscodium.repo"
[gitlab.com_paulcarroty_vscodium_repo]
name=download.vscodium.com
baseurl=https://download.vscodium.com/rpms/
enabled=0
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
metadata_expire=1h
EOF

# ensure Repo is temporarily enabled
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/vscodium.repo

# install dev tools packages
dnf5 install -y --setopt=install_weak_deps=False \
	android-tools \
	codium \
	git \
	just

# delete chinese README.md from just doc, because it troubles container installation via anaconda
# the reason is, that the filepath contains non utf8 compatible characters (chinese)
rm -f /usr/share/doc/just/README.*.md

# ensure Repo is disabled
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/vscodium.repo

# cleanup layer
/scripts/99_cleanup_layer.sh
