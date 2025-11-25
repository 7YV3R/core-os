#!/usr/bin/env bash

set -euox pipefail

# install KDE
dnf5 group install --best -y --nodocs \
	kde-desktop

# install KDE specific packages
dnf5 install --best --allowerasing -y --skip-unavailable --nodocs --setopt=install_weak_deps=False \
    kate \
	ksshaskpass \
    NetworkManager-wifi

# remove unwanted packages
dnf5 remove -y \
	kdeconnect \
	kdeconnect-sms \
	plasma-discover-offline-updates \
	plasma-discover-packagekit \
	plasma-pk-updates \
	plasma-x11 \
	plasma-workspace-x11

# setup sysusersd for abrt user
cat <<EOF > "/usr/lib/sysusers.d/abrt.conf"
#Type	Name	ID			    GECOS				Home directory Shell
u!      abrt    173             "Automatic Bug Reporting Tool (ABRT)"   /usr/sbin/nologin
g       abrt    173             -
EOF

# start directly into installed desktop environment
systemctl set-default graphical.target

# cleanup layer
/scripts/99_cleanup_layer.sh