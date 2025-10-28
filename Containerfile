# Build Args
ARG FEDORA_IMAGE="quay.io/fedora-ostree-desktops/kinoite"
ARG FEDORA_VERSION="42"
ARG FEDORA_VERSION_SURFACE="42"


# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /build_files
COPY system_files /system_files
COPY repo_files /repo_files
COPY dotconfig_files /dotconfig_files
COPY network_files /network_files

# define base image
FROM ${FEDORA_IMAGE}:${FEDORA_VERSION} as core-os-base

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

# Add Layer with containerization stuff
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/04_install_containerization.sh

# Add Layer with development environment
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/05_install_dev_environment.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

#---------------------------- core-os:asus-latest-----------------------------   

FROM core-os-base as core-os-asus

# Add Layer with Nvidia
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/06_install_nvidia.sh

# Add Layer with Asus related stuff
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/07_install_asus.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

#---------------------------- core-os:surface-latest-----------------------------

FROM core-os-base as core-os-surface

ARG FEDORA_VERSION_SURFACE=${FEDORA_VERSION_SURFACE}
ENV FEDORA_VERSION_SURFACE=${FEDORA_VERSION_SURFACE}

# Add Layer with Surface related stuff
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/09_install_surface.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
