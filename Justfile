image_name := env("BUILD_IMAGE_NAME", "localhost/core-os")
image_tag := env("BUILD_IMAGE_TAG", "fedora")
base_dir := env("BUILD_BASE_DIR", "./output")
filesystem := env("BUILD_FILESYSTEM", "btrfs")
builder_image_name := env("BUILDER_IMAGE_NAME", "quay.io/centos-bootc/bootc-image-builder")
builder_image_tag := env("BUILDER_IMAGE_TAG", "latest")
iso_config_file := env("ISO_CONFIG_FILE", "./config/iso.toml")
iso_type := env("ISO_TYPE", "anaconda-iso")

create-cryptographics:
    #!/usr/bin/env bash
    openssl req -new -x509 -newkey rsa:2048 -keyout "./keys/key.pem" \
        -outform DER -out "./keys/cert.der" -nodes -days 36500 \
        -subj "/CN=core-os/"

build-containerfile $image_name=image_name $image_tag=image_tag:
    #!/usr/bin/env bash
    if [ "${image_tag}" == "fedora" ]; then
        target="core-os-base"
    elif [ "${image_tag}" == "fedora-nvidia" ]; then
        target="core-os-nvidia"
    elif [ "${image_tag}" == "fedora-asus" ]; then
        target="core-os-asus"
    elif [ "${image_tag}" == "fedora-surface" ]; then
        target="core-os-surface"
    else
        target="core-os-base"
    fi

    sudo podman build --target=${target} -t "${image_name}:${image_tag}" .

update-current-system $image_name=image_name $image_tag=image_tag:
    sudo bootc switch --transport containers-storage \
        $(sudo podman images -q "${image_name}:${image_tag}")


generate-bootable-image $base_dir=base_dir $filesystem=filesystem:
    #!/usr/bin/env bash
    if [ ! -e "${base_dir}/bootable.img" ] ; then
        fallocate -l 20G "${base_dir}/bootable.img"
    fi
    just bootc install to-disk --composefs-backend --via-loopback /data/bootable.img \
        --filesystem "${filesystem}" --wipe --bootloader systemd


generate-installer-iso $image_name=image_name $image_tag=image_tag $iso_config_file=iso_config_file $base_dir=base_dir \
    $builder_image_name=builder_image_name $builder_image_tag=builder_image_tag $iso_type=iso_type:
    #!/usr/bin/env bash

    sudo podman run \
        --rm \
        -it \
        --privileged \
        --security-opt label=type:unconfined_t \
        -v ${iso_config_file}:/config.toml:ro \
        -v ${base_dir}:/output \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        ${builder_image_name}:${builder_image_tag} \
        --type ${iso_type} \
        --rootfs btrfs \
        --use-librepo=True \
        ${image_name}:${image_tag}