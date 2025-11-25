#!/usr/bin/env bash
set -euox pipefail

# setup needed variables
NVIDIA_CONTAINER_TOOLKIT_VERSION="1.18.0-1"


# install docker-ce repo as temporary repo
# to be able to install docker-ce environment
cat <<EOF > "/etc/yum.repos.d/docker-ce.repo"
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF

# install docker-ce repo as temporary repo
# to be able to install docker-ce environment
cat <<EOF > "/etc/yum.repos.d/nvidia-container-toolkit.repo"
[nvidia-container-toolkit]
name=nvidia-container-toolkit
baseurl=https://nvidia.github.io/libnvidia-container/stable/rpm/\$basearch
repo_gpgcheck=0
gpgcheck=0
enabled=1
gpgkey=https://nvidia.github.io/libnvidia-container/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

# create group for docker socket access
groupadd -f -g 952 docker
cat <<EOF > "/usr/lib/sysusers.d/docker.conf"
#Type	Name	ID			GECOS				Home directory Shell
g		docker	952			-
EOF

# install docker packages
dnf5 install --best -y --nodocs \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin

# install podman and additional containerization packages
dnf5 install --best -y --nodocs \
	podman-machine \
	podman-tui \
	podmansh \
	toolbox \
	xhost

# temporary fix because nvidia digest of packages is still messed up
echo "%_pkgverify_level none" >/etc/rpm/macros.verify

# install nvidia container toolkit
sudo dnf install -y \
	nvidia-container-toolkit-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
	nvidia-container-toolkit-base-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
	libnvidia-container-tools-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
	libnvidia-container1-${NVIDIA_CONTAINER_TOOLKIT_VERSION}

# reconfigure docker daemon
nvidia-ctk runtime configure --runtime=docker

# remove fix after install 
rm /etc/rpm/macros.verify

# install distrobox
wget -qO- https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh

# install flathub repository
flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Attention: these Flatpak applications will only be installed during the
# initial installation process. So modifying this list AFTER
# the initial installation by updating the image, will NOT add the
# Flathub applications to the system.
#
# This method currently generates a lot of Linting Warnings, because it
# manipulates the /var/lib folder and it will NOT be touched AFTER the
# initial installation process.
# We have to wait, till flathub finally integrates the command "preinstall".
# FIX this
flatpak install -y --system \
	com.ranfdev.DistroShelf \
	io.podman_desktop.PodmanDesktop

# install fix for gui applications in distrobox
mkdir -p /etc/skel
echo "xhost +si:localuser:\$USER >/dev/null" > /etc/skel/.distroboxrc
# for the current user:
# echo "xhost +si:localuser:$USER >/dev/null" > ~/.distroboxrc

# install X11 fix
install -Dm0755 /scripts/00_fix_display.sh /etc/profile.d/fix_display.sh

# enable services
systemctl enable docker
systemctl enable podmanfix

# remove temporary repos, so that they are not part of the image
rm -rf /etc/yum.repos.d/docker-ce.repo
rm -rf /etc/yum.repos.d/nvidia-container-toolkit.repo

# cleanup layer
/scripts/99_cleanup_layer.sh