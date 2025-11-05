#!/usr/bin/env bash


# installs kernel-installer-fix
fix_install(){
  mv /usr/lib/kernel/install.d/05-rpmostree.install /usr/lib/kernel/install.d/05-rpmostree.install.bak
  mv /usr/lib/kernel/install.d/50-dracut.install /usr/lib/kernel/install.d/50-dracut.install.bak
  printf '%s\n' '#!/bin/sh' 'exit 0' > /usr/lib/kernel/install.d/05-rpmostree.install
  printf '%s\n' '#!/bin/sh' 'exit 0' > /usr/lib/kernel/install.d/50-dracut.install
  chmod +x  /usr/lib/kernel/install.d/05-rpmostree.install /usr/lib/kernel/install.d/50-dracut.install
  echo "Kernel-installer-fix installed."
}

# uninstall kernel-installer-fix
fix_uninstall(){
  mv /usr/lib/kernel/install.d/05-rpmostree.install.bak /usr/lib/kernel/install.d/05-rpmostree.install
  mv /usr/lib/kernel/install.d/50-dracut.install.bak /usr/lib/kernel/install.d/50-dracut.install
  echo "Kernel-installer-fix removed."
}


if [ "${1}" == "install" ]; then
  fix_install
elif [ "${1}" == "uninstall" ]; then
  fix_uninstall
else
  echo "Unknown function."
  exit 1
fi
