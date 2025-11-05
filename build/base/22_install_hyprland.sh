#!/usr/bin/env bash

set -euox pipefail

# enable COPR Repo for hyprland
dnf5 copr enable -y solopasha/hyprland
dnf5 copr enable -y che/nerd-fonts

# install hyprland packages
dnf5 install --best --allowerasing -y --skip-unavailable \
    alacritty \
    bash-completion \
    brightnessctl \
    evince \
    gum \
    gvfs-mtp \
    gvfs-nfs \
    gvfs-smb \
    hypridle \
    hyprland \
    hyprland-qtutils \
    hyprlock \
    hyprpicker \
    hyprsunset \
    NetworkManager-tui \
    inxi \
    kvantum-qt5 \
    libsecret \
    libyaml \
    libqalculate \
    mako \
    nautilus \
    google-noto-fonts-all \
    Google-noto-emoji-fonts \
    pamixer \
    polkit \
    python-gobject \
    qt5-qtwayland \
    slurp \
    sushi \
    swaybg \
    cascadia-mono-nf-fonts \
    uwsm \
    waybar \
    wayfreeze \
    wiremix \
    wireplumber \
    wl-clipboard \
    wlogout \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal-hyprland \
    xdg-terminal-exec \
    yaru-icon-theme

# install nerd-fonts
dnf5 install -y nerd-fonts

# disable COPR Repo for hyprland
dnf5 copr disable -y solopasha/hyprland
dnf5 copr disable -y che/nerd-fonts