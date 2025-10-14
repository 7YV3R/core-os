#!/usr/bin/env bash

set -ouex pipefail

### Install hyprland packages

# enable hyprland copr
dnf5 -y copr enable solopasha/hyprland

# install hyprland packages
dnf5 install -y \
    alacritty \
    alsa-utils \
    blueman \
    brightnessctl \
    cascadia-code-fonts \
    fontawesome-fonts-all \
    google-noto-sans-cjk-fonts \
    grim \
    hyprland \
    hyprlock \
    hyprshot \
    jetbrains-mono-fonts-all \
    jq \
    kitty \
    libnotify \
    lxqt-policykit \
    nautilus \
    pamixer \
    pavucontrol \
    playerctl \
    rofi \
    slurp \
    swayimg \
    swappy \
    SwayNotificationCenter \
    swww \
    wofi \
    waybar \
    wl-clipboard \
    wlogout

# disable the copr for building the image
dnf5 -y copr disable solopasha/hyprland 

# install nerd-fonts
dnf5 copr enable che/nerd-fonts -y
dnf5 install -y nerd-fonts
dnf5 copr disable che/nerd-fonts -y

# copy custom dotconfig files into skel path for new users
mkdir -p /etc/skel/.config
cp -r /ctx/dotconfig_files/hypr /etc/skel/.config/
cp -r /ctx/dotconfig_files/swaync /etc/skel/.config/
cp -r /ctx/dotconfig_files/waybar /etc/skel/.config/
cp -r /ctx/dotconfig_files/wlogout /etc/skel/.config/
cp -r /ctx/dotconfig_files/wofi /etc/skel/.config/
