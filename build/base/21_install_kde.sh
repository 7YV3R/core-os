#!/usr/bin/env bash

set -euox pipefail

# install KDE
dnf5 group install -y kde-desktop

# install KDE specific packages
dnf5 install --best --allowerasing -y --skip-unavailable \
    kate

# setup sysusersd for abrt user
cat <<EOF > "/usr/lib/sysusers.d/abrt.conf"
#Type	Name	ID			    GECOS				Home directory Shell
u!      abrt    173             "Automatic Bug Reporting Tool (ABRT)"   /usr/sbin/nologin
g       abrt    173             -
EOF

# start directly into KDE
systemctl set-default graphical.target