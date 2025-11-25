#!/usr/bin/env bash

set -eoux pipefail

if [ -z "${kver}" ]; then
  kver="$(/scripts/10_get_kernel_version.sh)"
fi

# debug info
echo "Building initramfs for Kernel '${kver}'..."

# Ensure Initramfs is generated
export DRACUT_NO_XATTR=1
/usr/bin/dracut --no-hostonly --kver "${kver}" --reproducible -v --add ostree -f "/usr/lib/modules/${kver}/initramfs.img"
chmod 0600 "/usr/lib/modules/${kver}/initramfs.img"