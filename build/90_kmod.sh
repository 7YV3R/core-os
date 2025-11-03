#!/usr/bin/env bash
set -euox pipefail

# get the newest installed kernel version
kver=$(rpm -q kernel | sort -V | head -n 1 | cut -d' ' -f1 | sed 's/^kernel-//')

# create a fake uname binary
# because the original would show the (builder) hosts kernel version
cat >/tmp/fake-uname <<EOF
#!/usr/bin/env bash
if [ "\$1" == "-r" ] ; then
  echo ${kver}
  exit 0
fi
exec /usr/bin/uname \$@
EOF

# install fake uname into tmp for usage
install -Dm0755 /tmp/fake-uname /tmp/bin/uname

# workaround for akmod permission issue
chmod 777 /var/tmp

# PATH=/tmp/bin:$PATH dkms autoinstall -k ${kver}
PATH=/tmp/bin:$PATH akmods --force --kernels ${kver}

# remove fake uname
rm -rf /tmp/fake-uname /tmp/bin/uname

# revert permissions
chmod 755 /var/tmp
