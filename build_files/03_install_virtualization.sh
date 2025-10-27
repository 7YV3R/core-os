#!/usr/bin/env bash

set -ouex pipefail

### Install virtualization/containerization environment

# install dev tools packages
dnf5 install -y --setopt=install_weak_deps=False \
	edk2-ovmf \
	libvirt \
	libvirt-nss \
	libvirt-dbus \
	openvswitch \
	qemu \
	qemu-char-spice \
	qemu-device-display-virtio-gpu \
	qemu-device-display-virtio-vga \
	qemu-device-usb-redirect \
	qemu-img \
	qemu-system-x86-core \
	qemu-user-binfmt \
	qemu-user-static \
	virt-manager \
	virt-v2v \
	virt-viewer

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

# ensure default network for virtual environment is running
mkdir -p /var/lib/libvirt/dnsmasq

# Cleanup
dnf5 clean all
rm -rf /var/cache/dnf