# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /build_files
COPY system_files /system_files
COPY repo_files /repo_files
COPY dotconfig_files /dotconfig_files
COPY network_files /network_files

# define base image
FROM quay.io/fedora-ostree-desktops/kinoite:42 as coreos:latest

# Add Layer with extended system modifications
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/01_install_extended_system.sh

# Add Layer with Hyprland
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/02_install_hyprland.sh

# Add Layer with Virtualization
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/03_install_virtualization.sh

# Add Layer with development environment
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/04_install_dev_environment.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

#---------------------------- coreos:asus-latest-----------------------------   

FROM coreos:latest as coreos:asus-latest

# Add Layer with Nvidia
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/05_install_nvidia.sh

# Add Layer with Asus related stuff
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/08_install_asus.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

#---------------------------- coreos:surface-latest-----------------------------

FROM coreos:latest as coreos:surface-latest

# Add Layer with Surface related stuff
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/09_install_surface.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
