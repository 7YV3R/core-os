#!/usr/bin/env bash

set -euox pipefail

# install wifi firmware
dnf5 install --best --allowerasing -y --skip-unavailable \
	atheros-firmware \
	atmel-firmware \
	b43-fwcutter \
	b43-openfwwf \
	brcmfmac-firmware \
	iwlegacy-firmware \
	iwlwifi-dvm-firmware \
	iwlwifi-mvm-firmware \
	libertas-firmware \
	mt7xxx-firmware \
	nxpwireless-firmware \
	realtek-firmware \
	tiwilink-firmware \
	zd1211-firmware

# cleanup layer
/scripts/99_cleanup_layer.sh