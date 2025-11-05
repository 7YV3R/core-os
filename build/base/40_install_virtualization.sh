#!/usr/bin/env bash

set -euox pipefail

# install virtualization environment
dnf5 group install -y --skip-unavailable \
    virtualization

# enable services
systemctl enable libvirtd.socket

# cleanup layer
/scripts/99_cleanup_layer.sh