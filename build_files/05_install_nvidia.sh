#!/usr/bin/env bash

set -ouex pipefail

### Install Nvidia driver

# Activate RPM Fusion Free Repository
dnf5 install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

# Activate RPM Fusion Non-Free Repository
dnf5 install -y \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# install prepared repo files
mkdir -p /etc/yum.repos.d
cp /ctx/repo_files/nvidia-container-toolkit.repo /etc/yum.repos.d/

# ensure Repo is temporarily enabled
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/nvidia-container-toolkit.repo

# install dev tools packages
dnf5 install -y --setopt=install_weak_deps=False \
	akmod-nvidia \
  nvidia-container-toolkit \
	xorg-x11-drv-nvidia-cuda

# install Kernel args
cp /ctx/system_files/10_nvidia.toml /usr/lib/bootc/kargs.d/10-nvidia.toml


### Kernel Mod
### based on https://mrguitar.net/?p=2664

# get modules
kver=$(cd /usr/lib/modules && echo *)

# create a fake unmae binary
cat >/tmp/fake-uname <<EOF
#!/usr/bin/env bash

if [ "\$1" == "-r" ] ; then
  echo ${kver}
  exit 0
fi

exec /usr/bin/uname \$@
EOF
install -Dm0755 /tmp/fake-uname /tmp/bin/uname

# install kernel modules
PATH=/tmp/bin:$PATH dkms autoinstall -k ${kver}
PATH=/tmp/bin:$PATH akmods --force --kernels ${kver}

# ensure Repo is disabled
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/nvidia-container-toolkit.repo

# Cleanup
dnf5 clean all
rm -rf /var/cache/dnf