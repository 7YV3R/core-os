#!/usr/bin/env bash

set -eou pipefail

# return current installed kernel version
kver="$(rpm -q --queryformat="%{evr}.%{arch}" kernel-core)"
echo ${kver}