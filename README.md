# Core-OS

This repo represents my personal steps into the amzing world of Atomic Desktop.
Started off by tinkering with Aurora (KDE Spin-Off from Universal Blue), but got frustrated
with all the (very intense) customization and modifications of Fedora Kinoite.

So tried to build my own custom spin of Fedora Kinoite (KDE Spin of Fedoras Atomic Desktop).

I'm a big fan of the Atomic Desktop philosophy to create a core os, which
- can be customized like Podman/Docker environments and boot like a normal os
- is immutable at its core
- atomic updates
- sume kind of different stages at boot time
- layers applications via Flatpak, Appimage, Distrobox or normal containers on top of it
- can be swapped easily with another Atomic Desktops (Bazzite for Gaming and Fedora for work-stuff)

# Warning
This Repo is far from being production-ready and more an experiment to create a customized
Atomic Desktop, to fit my personal needs.
**SELinux has been set to permissive because of all the tests and development steps !!**

# (personal) Goals
- Core OS
- NVIDIA Support
- Hyprland and KDE (because this Atomic Desktop is mostly used on convertibles/tablets and KDE is best with touchdisplays)
- Working on ASUS and Surface devices
- Support for virtualization with Firewall (VM) seperated VMs
- Easy customization

# Building
Building the image has been best-fitted for Podman usage on local instances. Yeah, it's a little bit rough at the moment.

## Building the image locally
``sudo podman build -t core-os:latest .``

## Switch to the new image
``sudo bootc switch --transport containers-storage $(sudo podman images -q core-os)``

# Credits
- Most of the Hyprland DotFiles are based on or directly from **JaKooLit's** repository (https://github.com/JaKooLit/Hyprland-Dots). 
- Also most of the wallpaper files are from **JaKooLit's** repo. (https://github.com/JaKooLit/Wallpaper-Bank)

