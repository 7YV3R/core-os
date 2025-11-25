#!/usr/bin/env bash

# Because the standard uname binary returns kernel information
# from the container host and not from the container itself,
# this script has to be used instead.
# This fake uname binary will only return the installed kernel version
# from the container. This is needed for all "akmod" and "dracut"
# operations.

if [ -z "${kver}" ]; then
  kver="$(/scripts/10_get_kernel_version.sh)"
fi

# return kernel version
if [ "\$1" == "-r" ] ; then
  echo ${kver}
  exit 0
fi
exec /usr/bin/uname_orig "$@"