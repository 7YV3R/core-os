ARG BASE_IMAGE_NAME="quay.io/fedora/fedora-bootc"
ARG BASE_IMAGE_TAG="43"

#---------------------------------- base build layer -----------------------------------------
# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS build-base
# copy over the build files
COPY --chmod=755 build/base/* /

#---------------------------------- nvidia build layer -----------------------------------------
# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS build-nvidia
# copy over the build files
COPY --chmod=755 build/nvidia/* /

#---------------------------------- asus build layer -----------------------------------------
# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS build-asus
# copy over the build files
COPY --chmod=755 build/asus/* /

#---------------------------------- surface build layer -----------------------------------------
# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS build-surface
# copy over the build files
COPY --chmod=755 build/surface/* /

#---------------------------------- shared scripts layer -----------------------------------------
# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS scripts-shared
# copy over the build files
COPY --chmod=755 scripts/shared/* /

#---------------------------------- surface scripts layer -----------------------------------------
# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS scripts-surface
# copy over the build files
COPY --chmod=755 scripts/surface/* /

#-----------------------------------core os base ----------------------------------------
FROM ${BASE_IMAGE_NAME:-quay.io/fedora/fedora-bootc}:${BASE_IMAGE_TAG:-43} AS core-os-base

# make usage of build arguments during build-time
ARG BASE_IMAGE_TAG

# make build arguments available as environment variables
ENV BASE_IMAGE_TAG="${BASE_IMAGE_TAG}"

# setup etc
COPY system/base/etc etc
# copy plymouth themes
COPY system/base/plymouth usr/share/plymouth

# setup base image
RUN --mount=type=bind,from=build-base,source=/,target=/build \
    --mount=type=bind,from=scripts-shared,source=/,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/00_prepare_base.sh

# install firmware
RUN --mount=type=bind,from=build-base,source=/,target=/build \
    --mount=type=bind,from=scripts-shared,source=/,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/05_install_firmware.sh

# install and setup desktop environment
RUN --mount=type=bind,from=build-base,source=/,target=/build \
    --mount=type=bind,from=scripts-shared,source=/,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/20_install_desktop_environment.sh

# install containerization environment
RUN --mount=type=bind,from=build-base,source=/,target=/build \
    --mount=type=bind,from=scripts-shared,source=/,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/30_install_containerization.sh

# install virtualization environment
RUN --mount=type=bind,from=build-base,source=/,target=/build \
    --mount=type=bind,from=scripts-shared,source=/,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/40_install_virtualization.sh

# install development environment
RUN --mount=type=bind,from=build-base,source=/,target=/build \
    --mount=type=bind,from=scripts-shared,source=/,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/50_install_dev_env.sh

# install systemwide flatpacks
RUN --mount=type=bind,from=build-base,source=/,target=/build \
    --mount=type=bind,from=scripts-shared,source=/,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/60_install_flatpak.sh

# setup usr
COPY system/base/usr usr

# Cleanup base image
RUN --mount=type=bind,from=build-base,source=/,target=/build \
    --mount=type=bind,from=scripts-shared,source=/,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/99_cleanup_image.sh

#-----------------------------------core os NVIDIA ----------------------------------------
FROM core-os-base AS core-os-nvidia

# setup etc
COPY system/nvidia/etc etc

# setup usr
COPY system/nvidia/usr usr

# build the ASUS image by invoking the ASUS build script
RUN --mount=type=bind,from=build-nvidia,source=/,target=/build \
    --mount=type=bind,from=scripts-shared,source=/,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/00_install_nvidia.sh

# install systemwide flatpacks
RUN --mount=type=bind,from=build-base,source=/,target=/build \
    --mount=type=bind,from=scripts-shared,source=/,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/99_cleanup_image.sh

#-----------------------------------core os Asus ----------------------------------------
FROM core-os-nvidia AS core-os-asus

# build the Asus image by invoking the Asus build script
RUN --mount=type=bind,from=build-asus,source=/,target=/build \
    --mount=type=bind,from=scripts-shared,source=/,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/00_install_asus.sh

# install systemwide flatpacks
RUN --mount=type=bind,from=build-asus,source=/,target=/build \
    --mount=type=bind,from=scripts-shared,source=/,target=/scripts \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/99_cleanup_image.sh

#-----------------------------------core os asus ----------------------------------------
FROM core-os-base AS core-os-surface

# make usage of build arguments during build-time
ARG BASE_IMAGE_TAG

# make build arguments available as environment variables
ENV BASE_IMAGE_TAG="${BASE_IMAGE_TAG}"

# setup etc
COPY system/surface/etc etc

# setup usr
COPY system/surface/usr usr

# build the Surface image by invoking the Surface build script
RUN --mount=type=bind,from=build-surface,source=/,target=/build \
    --mount=type=bind,from=scripts-shared,source=/,target=/scripts \
    --mount=type=bind,from=scripts-surface,source=/,target=/surface \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/00_install_surface.sh

# install systemwide flatpacks
RUN --mount=type=bind,from=build-surface,source=/,target=/build \
    --mount=type=bind,from=scripts-shared,source=/,target=/scripts \
    --mount=type=bind,from=scripts-surface,source=/,target=/surface \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/99_cleanup_image.sh