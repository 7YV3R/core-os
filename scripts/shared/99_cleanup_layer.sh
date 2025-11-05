#!/usr/bin/env bash

set -euox pipefail

# perform cleanup
dnf5 clean all
rm -rf /var/run*
rm -rf /var/cache/dnf*
rm -rf /boot/* && rm -rf /boot/.*
rm -rf /tmp/* && rm -rf /tmp/.*