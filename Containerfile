ARG BASE_IMAGE_NAME="quay.io/fedora/fedora-bootc"
ARG BASE_IMAGE_TAG="43"
ARG INSTALL_NVIDIA="true"

#---------------------------------- build layer -----------------------------------------
# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
# copy over the build files
COPY --chmod=755 build/* /build/

#-----------------------------------core os base ----------------------------------------
FROM ${BASE_IMAGE_NAME:-quay.io/fedora/fedora-bootc}:${BASE_IMAGE_TAG:-43} AS core-os-base

# make usage of build arguments during build-time
ARG BASE_IMAGE_TAG
ARG INSTALL_NVIDIA

# make build arguments available as environment variables
ENV BASE_IMAGE_TAG="${BASE_IMAGE_TAG}"
ENV INSTALL_NVIDIA="${INSTALL_NVIDIA}"

# setup etc
COPY system/etc etc
# copy plymouth themes
COPY plymouth usr/share/plymouth

# build the base image by invoking the build script
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/00_build.sh

# setup usr
COPY system/usr usr

#added linting to catch basic issues
RUN bootc container lint

#-----------------------------------core os asus ----------------------------------------
FROM core-os-base AS core-os-asus

# build the ASUS image by invoking the ASUS build script
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/80_install_asus.sh

#added linting to catch basic issues
RUN bootc container lint