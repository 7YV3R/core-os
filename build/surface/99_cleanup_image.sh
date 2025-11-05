#!/usr/bin/env bash

set -euox pipefail

# uninstall fake uname
/scripts/10_uname_installer.sh uninstall

# uninstall kernel-installer-fix
/surface/10_kernel_installer_fix.sh uninstall

# check and cleanup image
bootc container lint