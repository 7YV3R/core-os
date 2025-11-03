#!/usr/bin/env bash
if [ "\$1" == "-r" ] ; then
  echo ${kver}
  exit 0
fi
exec /usr/bin/uname \$@