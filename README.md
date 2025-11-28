# Core-OS

This repo represents my personal steps into the amzing world of Atomic Desktop in addition with bootc.
Started off by tinkering with Aurora (KDE Spin-Off from Universal Blue), but got frustrated
with all the (very intense) customization and modifications of Fedora Kinoite. So tried to build my 
own custom spin of Fedora Kinoite (KDE Spin of Fedoras Atomic Desktop).

After this sidestep i discovered the world of bootc. 

Now I'm a big fan of the bootc philosophy to create a core os, which
- can be customized like Podman/Docker environments and boot like a normal os
- is immutable at its core
- enables some kind of different stages at boot time
- allow an abstraction and isolation of applications via Flatpak, Appimage, Distrobox or normal containers on top of it
- can be swapped easily with another bootc based OSes

# Warning
This Repo is far from being production-ready and more an experiment to create a customized
Atomic Desktop, to fit my personal needs.
**SELinux has been set to permissive because of all the tests and development steps !!**

# (personal) Goals
- Core OS
- NVIDIA Support
- KDE as main Desktop Environment
- Working on ASUS devices
- Working on Surface devices
- Support for virtualization and containerization
- Easy customization

# Building
This repo is ment to be used for local building.

## Building the image locally
To build the *core-os* base image, execute
```
just build-containerfile localhost/core-os fedora
``` 

To build the *core-os* image with NVIDIA drivers, execute
```
just build-containerfile localhost/core-os fedora-nvidia
```

To build the *core-os* image for Asus machines, execute
```
just build-containerfile localhost/core-os fedora-asus
```

To build the *core-os* image for Surface machines, execute
```
just build-containerfile localhost/core-os fedora-surface
```


## Switch to the new image
To use the *core-os* base image, execute
```
just update-current-system localhost/core-os fedora
```

To use the *core-os* Asus image, execute
```
just update-current-system localhost/core-os fedora-asus
```                                                                                 

To use the *core-os* Surface image, execute
```
just update-current-system localhost/core-os fedora-surface
```

If something goes wrong with the new image, reboot and choose the previous build in the boot menu.
After boot completed successfull with the old version, execute ``sudo bootc rollback``. The current booted
image will be used as standard.

## Build ISO
Use the Justfile with following command:
```
just generate-installer-iso localhost/core-os fedora-asus
```


# Credits
- I learned a lot by examining **mrguitar's** (https://github.com/mrguitar) bootc repos, especially the **fedora-nvidia-bootc** one (https://github.com/mrguitar/fedora-nvidia-bootc/). In fact, i started my repo by tinkering with a clone of his *fedora-nvidia-bootc* repo.
- The **Aurora** repository of the **Universal Blue** Project (https://github.com/ublue-os/aurora) was a huge source of inspiration and provided some Containerfile basics and script snippets for handling the build process.
- All the stuff needed to build ISOs to (inatially) install the bootc image to baremetal, has been derived from https://osbuild.org/docs/bootc/
- Plymouth Themes from **Aditya Shakya (adi1090x)** @GitHub (https://github.com/adi1090x/plymouth-themes)
