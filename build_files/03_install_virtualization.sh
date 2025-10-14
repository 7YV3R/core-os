#!/usr/bin/env bash

set -ouex pipefail

### Install virtualization/containerization environment

# install prepared repo files
mkdir -p /etc/yum.repos.d
cp /ctx/repo_files/nvidia-container-toolkit.repo /etc/yum.repos.d/

# ensure Repo is temporarily enabled
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/nvidia-container-toolkit.repo

# install dev tools packages
dnf5 install -y \
	distrobox \
	edk2-ovmf \
	libvirt \
	libvirt-nss \
	libvirt-dbus \
	nvidia-container-toolkit \
	openvswitch \
	podman-compose \
	podman-docker \
	podman-machine \
	podman-tui \
	podmansh \
	qemu \
	qemu-char-spice \
	qemu-device-display-virtio-gpu \
	qemu-device-display-virtio-vga \
	qemu-device-usb-redirect \
	qemu-img \
	qemu-system-x86-core \
	qemu-user-binfmt \
	qemu-user-static \
	toolbox \
	virt-manager \
	virt-v2v \
	virt-viewer \
	xhost

# setup openvswitch
mkdir -p /var/log/openvswitch
mkdir -p /run/openvswitch
mkdir -p /etc/openvswitch
chown -R openvswitch:openvswitch /var/log/openvswitch /run/openvswitch /etc/openvswitch
cd /etc/openvswitch && ovsdb-tool create
systemctl enable openvswitch


# setup prepared networks
mkdir -p /etc/libvirt/qemu/networks/autostart
cp /ctx/network_files/mgmt.xml /etc/libvirt/qemu/networks/
cp /ctx/network_files/trunk.xml /etc/libvirt/qemu/networks/
ln -s /etc/libvirt/qemu/networks/mgmt.xml /etc/libvirt/qemu/networks/autostart/mgmt.xml 
ln -s /etc/libvirt/qemu/networks/trunk.xml /etc/libvirt/qemu/networks/autostart/trunk.xml 

# install fix for gui applications in distrobox
mkdir -p /etc/skel
echo "xhost +si:localuser:\$USER >/dev/null" > /etc/skel/.distroboxrc
# for the current user:
# echo "xhost +si:localuser:$USER >/dev/null" > ~/.distroboxrc

# ensure default network for virtual environment is running
mkdir -p /var/lib/libvirt/dnsmasq

# ensure Repo is disabled
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/nvidia-container-toolkit.repo
