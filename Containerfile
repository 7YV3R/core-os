ARG BASE_IMAGE_NAME="quay.io/fedora/fedora-bootc"
ARG BASE_IMAGE_TAG="43"

#---------------------------------- veracrypt builder -----------------------------------------
# Builing Veracrypt in an builder container and copy over the final binary
FROM docker.io/library/debian:13 AS veracrypt-builder
RUN apt update && apt install -y \
    build-essential git make yasm pkg-config libwxgtk3.2-dev libfuse-dev git libpcsclite-dev yasm pkg-config libpcsclite-dev
RUN mkdir /build/ && cd /build && git clone https://github.com/veracrypt/VeraCrypt.git && cd VeraCrypt/src && make 

#-----------------------------------core os init ----------------------------------------
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG} AS core-os-init

# make usage of build arguments during build-time
ARG BASE_IMAGE_TAG
# make build arguments available as environment variables
ENV BASE_IMAGE_TAG="${BASE_IMAGE_TAG}"

# setup etc
COPY system_files/base/etc etc
# copy plymouth themes
COPY system_files/base/plymouth usr/share/plymouth
# setup usr
COPY system_files/base/usr usr
# copy cryptographic material, if there is anything
COPY --chmod=644 keys/ /tmp/

# setup base image
RUN --mount=type=bind,source=scripts/build/base/00_prepare_base.sh,target=/build/00_prepare_base.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/00_prepare_base.sh

# install firmware
RUN --mount=type=bind,source=scripts/build/base/05_install_firmware.sh,target=/build/05_install_firmware.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/05_install_firmware.sh

#-----------------------------------core os DE ----------------------------------------
FROM core-os-init AS core-os-de

# install and setup KDE
RUN --mount=type=bind,source=scripts/build/base/10_install_kde.sh,target=/build/10_install_kde.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/10_install_kde.sh

# setup theming
COPY system_files/base/theme usr/share/

#-----------------------------------core os base ----------------------------------------
FROM core-os-de AS core-os-base

# install and setup hyperland
RUN --mount=type=bind,source=scripts/build/base/15_install_hyprland.sh,target=/build/15_install_hyprland.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/15_install_hyprland.sh

# install and setup base software
RUN --mount=type=bind,source=scripts/build/base/20_setup_base_software.sh,target=/build/20_setup_base_software.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/20_setup_base_software.sh

# copy compiled veracrypt binary to main image
COPY --from=veracrypt-builder /build/VeraCrypt/src/Main/veracrypt /usr/local/bin/veracrypt

# install containerization environment
RUN --mount=type=bind,source=scripts/build/base/30_install_containerization.sh,target=/build/30_install_containerization.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/30_install_containerization.sh

# install virtualization environment
RUN --mount=type=bind,source=scripts/build/base/40_install_virtualization.sh,target=/build/40_install_virtualization.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/40_install_virtualization.sh

# install development environment
RUN --mount=type=bind,source=scripts/build/base/50_install_dev_env.sh,target=/build/50_install_dev_env.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/50_install_dev_env.sh

# install systemwide flatpacks
RUN --mount=type=bind,source=scripts/build/base/60_install_flatpak.sh,target=/build/60_install_flatpak.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/60_install_flatpak.sh

# Cleanup base image
RUN --mount=type=bind,source=scripts/build/base/99_cleanup_image.sh,target=/build/99_cleanup_image.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/99_cleanup_image.sh

#-----------------------------------core os Nvidia ----------------------------------------
FROM core-os-base AS core-os-nvidia

# make usage of build arguments during build-time
ARG BASE_IMAGE_TAG
# make build arguments available as environment variables
ENV BASE_IMAGE_TAG="${BASE_IMAGE_TAG}"

# setup usr
COPY system_files/nvidia/usr usr

# build the Nvidia image by invoking the Nvidia build script
RUN --mount=type=bind,source=scripts/build/nvidia/00_install_nvidia.sh,target=/build/00_install_nvidia.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/00_install_nvidia.sh

# cleanup Nvidia image
RUN --mount=type=bind,source=scripts/build/nvidia/99_cleanup_image.sh,target=/build/99_cleanup_image.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/99_cleanup_image.sh

#-----------------------------------core os Asus ----------------------------------------
FROM core-os-nvidia AS core-os-asus

# build the Asus image by invoking the Asus build script
RUN --mount=type=bind,source=scripts/build/asus/00_install_asus.sh,target=/build/00_install_asus.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/00_install_asus.sh

# cleanup Asus image
RUN --mount=type=bind,source=scripts/build/asus/99_cleanup_image.sh,target=/build/99_cleanup_image.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/99_cleanup_image.sh

#-----------------------------------core os Surface ----------------------------------------
FROM core-os-base AS core-os-surface

# make usage of build arguments during build-time
ARG BASE_IMAGE_TAG
# make build arguments available as environment variables
ENV BASE_IMAGE_TAG="${BASE_IMAGE_TAG}"

# setup etc
COPY system_files/surface/etc etc

# setup usr
COPY system_files/surface/usr usr

# build the Surface image by invoking the Surface build script
RUN --mount=type=bind,source=scripts/build/surface/00_install_surface.sh,target=/build/00_install_surface.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=bind,source=scripts/functions/surface,target=/surface \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/00_install_surface.sh

# cleanup surface image
RUN --mount=type=bind,source=scripts/build/surface/99_cleanup_image.sh,target=/build/99_cleanup_image.sh \
    --mount=type=bind,source=scripts/functions/shared,target=/scripts \
    --mount=type=bind,source=scripts/functions/surface,target=/surface \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/99_cleanup_image.sh