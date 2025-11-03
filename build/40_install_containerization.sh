#!/usr/bin/env bash

set -euox pipefail

# ensure Repo is temporarily enabled
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/docker-ce.repo

# create group for docker socket access
groupadd -f -g 952 docker
cat <<EOF > "/usr/lib/sysusers.d/docker.conf"
#Type	Name	ID			GECOS				Home directory Shell
g		docker	952			-
EOF

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

# distrobox patch according to
# - https://github.com/89luca89/distrobox/issues/1865
sed -i 's/set -- "su" /set -- "su" "--login" /' /usr/bin/distrobox-enter

# install fix for gui applications in distrobox
mkdir -p /etc/skel
echo "xhost +si:localuser:\$USER >/dev/null" > /etc/skel/.distroboxrc
# for the current user:
# echo "xhost +si:localuser:$USER >/dev/null" > ~/.distroboxrc

# install X11 fix
install -Dm0755 /ctx/build/91_fix_display.sh /etc/profile.d/fix_display.sh


# enable services
systemctl enable docker
systemctl enable podmanfix
systemctl enable podman-auto-update.timer

# ensure Repo is disabled
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/docker-ce.repo