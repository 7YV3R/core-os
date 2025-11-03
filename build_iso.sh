#!/usr/bin/env bash

BOOTC_IMAGE_BUILDER_NAME="quay.io/centos-bootc/bootc-image-builder"
BOOTC_IMAGE_BUILDER_TAG="latest"
BOOTC_IMAGE="localhost/core-os:latest"
ISO_CONFIG_FILE="./config/iso.toml"
OUTPUT_PATH="./output"

check_root(){
    if [ "$EUID" -ne 0 ];then 
        echo "Please run with priviledged rights (root or sudo)."
        exit 1
    fi
}

build_iso(){
    if [ -n "${1}" ]; then
        BOOTC_IMAGE="${1}"
        echo "Going to use '${BOOTC_IMAGE}'."
    else
        echo "Not provided a image. Using the default image '${BOOTC_IMAGE}' "
    fi

    sudo podman run \
    --rm \
    -it \
    --privileged \
    --security-opt label=type:unconfined_t \
    -v ${ISO_CONFIG_FILE:-./config/iso.toml}:/config.toml:ro \
    -v ${OUTPUT_PATH:-./output}:/output \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    ${BOOTC_IMAGE_BUILDER_NAME:-quay.io/centos-bootc/bootc-image-builder}:${BOOTC_IMAGE_BUILDER_TAG:-latest} \
    --type anaconda-iso \
    --rootfs btrfs \
	--use-librepo=True \
    ${BOOTC_IMAGE:-localhost/core-os:latest}
}


check_root
build_iso ${1}