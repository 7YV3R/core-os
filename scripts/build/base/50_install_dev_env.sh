#!/usr/bin/env bash

set -euox pipefail

# install vscodium repo as temporary repo
# to be able to install vscode
cat <<EOF > "/etc/yum.repos.d/vscodium.repo"
[gitlab.com_paulcarroty_vscodium_repo]
name=download.vscodium.com
baseurl=https://download.vscodium.com/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
metadata_expire=1h
EOF

# install dev tools packages
# - install VSCodium instead of VScode and
# - install VSCodium nativly (not as Flatpak), because so it's 
#   possible to access filesystem and docker/podman capabilities
dnf5 install -y --nodocs \
	android-tools \
	codium \
	git \
	just

# delete chinese README.md from just doc, because it troubles container installation via anaconda
# the reason is, that the filepath contains non utf8 compatible characters (chinese)
rm -f /usr/share/doc/just/README.*.md

# remove temporary repos, so that they are not part of the image
rm -rf /etc/yum.repos.d/vscodium.repo

# cleanup layer
/scripts/99_cleanup_layer.sh
