#!/usr/bin/env bash

set -eou pipefail

# return current installed surface kernel version
kver="$(rpm -q --queryformat="%{evr}.%{arch}" kernel-surface)"
echo ${kver}