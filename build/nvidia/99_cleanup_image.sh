#!/usr/bin/env bash

set -euox pipefail

# uninstall fake uname
/scripts/10_uname_installer.sh uninstall

# check and cleanup image
bootc container lint