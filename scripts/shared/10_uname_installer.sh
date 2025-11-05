#!/usr/bin/env bash

# Because the standard uname binary returns kernel information
# from the container host and not from the container itself,
# this script is for installing temporarily a fake uname.
# This fake uname binary will only return the installed kernel version
# from the container. This is needed for all "akmod" and "dracut"
# operations.

# installs fake uname
uname_install(){
    # make a backup of the original binary
    cp /usr/bin/uname /usr/bin/uname_orig
    # remove original binary
    rm -f /usr/bin/uname
    #install fake uname
    install -Dm0755 /scripts/00_fake_uname.sh /usr/bin/uname
    echo "Installed fake uname binary."
}

# uninstall fake uname
uname_uninstall(){
    # remove fake uname
    rm -f /usr/bin/uname
    #restore original uname binary
    cp /usr/bin/uname_orig /usr/bin/uname
    echo "Uninstalled fake uname binary."
}


if [ "${1}" == "install" ]; then
  uname_install
elif [ "${1}" == "uninstall" ]; then
  uname_uninstall
else
  echo "Unknown function."
  exit 1
fi
