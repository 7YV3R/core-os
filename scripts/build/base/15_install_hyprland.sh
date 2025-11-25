#!/usr/bin/env bash
set -euox pipefail

# enable COPR Repo for hyprland
dnf5 copr enable -y solopasha/hyprland
dnf5 copr enable -y che/nerd-fonts

# install hyprland packages
dnf5 install --best --allowerasing -y --skip-unavailable --nodocs --setopt=install_weak_deps=False \
    alacritty \
    bash-completion \
    brightnessctl \
    cascadia-mono-nf-fonts \
    evince \
    google-noto-emoji-fonts \
    gum \
    gvfs-mtp \
    gvfs-nfs \
    gvfs-smb \
    hypridle \
    hyprland \
    hyprlock \
    hyprpicker \
    hyprsunset \
    inxi \
    kvantum-qt6 \
    libsecret \
    libyaml \
    libqalculate \
    mako \
    nautilus \
    NetworkManager-tui \
    pamixer \
    polkit \
    polkit-kde \
    python-gobject \
    qt6-base \
    qt6-base-devel \
    qt6-qtwayland \
    slurp \
    sushi \
    swaybg \
    uwsm \
    waybar \
    wiremix \
    wireplumber \
    wl-clipboard \
    wlogout \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal-hyprland \
    xdg-terminal-exec \
    yaru-icon-theme

# install nerd-fonts
dnf5 install -y --nodocs --setopt=install_weak_deps=False \
    nerd-fonts

# remove COPR Repo for hyprland
dnf5 copr remove -y solopasha/hyprland
dnf5 copr remove -y che/nerd-fonts

# cleanup layer
/scripts/99_cleanup_layer.sh