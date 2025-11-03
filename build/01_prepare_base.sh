#!/usr/bin/env bash
set -euox pipefail

# create root home
mkdir -p /var/roothome 
mkdir -p /usr/lib/sysusers.d

# Install new dnf5 implementation if not available
# all following manipulations need dnf5
if ! rpm -q dnf5 >/dev/null; then
    dnf install dnf5 dnf5-plugins
fi

# set SELinux to permissive mode
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# disable hibernation and sleep
systemctl mask sleep.target 
systemctl mask suspend.target 
systemctl mask hibernate.target 
systemctl mask hybrid-sleep.target

# disable bluetooth at start
systemctl disable bluetooth.service