#!/bin/bash
# shellcheck disable=SC2034

#############################################################
#                   ATUI build script                       #
#############################################################

# Archiso variables
iso_name="atui"
iso_version="0.0.1"
iso_label="ATUIISO_001"
iso_publisher="ATUI <https://github.com/PandaFoss/ATUI>"
install_dir="arch"
bootmodes="('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')"
arch="x86_64"
pacman_conf="pacman.conf"

# ATUI specific variables
BUILD_DIR="$(pwd)/atui_build"
ARCHISO_DIR="/usr/share/archiso/configs/releng"

# Check root permission
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Please run as root"
        exit
    fi
}

# Check if archiso is installed
check_archiso() {
    if ! sudo pacman -Qqs '^archiso$' >/dev/null \
    || ! sudo pacman -Qqs '^mkinitcpio-archiso$' >/dev/null; then
        printf "archiso or mkinitcpio-archiso was not found.\n"
        printf "Do you want to install it? [Y/n] "
        read -r answer
        if [ "${answer}" != "${answer#[Yy]}" ] ;then
            sudo pacman -Syy archiso mkinitcpio-archiso --needed
        else
            echo "archiso and mkinitcpio-archiso are required. Please install it before continuing."
            exit 1
        fi
        exit
    fi
}

create_build_dir() {
    # Create temporary directory if not exists
    [ -d "${BUILD_DIR}" ] || mkdir "${BUILD_DIR}"

    # Copy archiso files to tmp dir
    sudo cp -r "${ARCHISO_DIR}"/* "${BUILD_DIR}"

    # Copy ATUI files to tmp dir
    sudo cp -Tr "$(pwd)/src/airootfs/root" "${BUILD_DIR}/airootfs/root"

    # Add ATUI packages
    cat "$(pwd)/atui-packages.x86_64" >> "${BUILD_DIR}/packages.x86_64"
    sort --unique --output="${BUILD_DIR}/packages.x86_64" "${BUILD_DIR}/packages.x86_64"
}

# Generate profiledef.sh file
profiledef_gen() {
    [ ! -f "${BUILD_DIR}"/profiledef.sh ] || rm "${BUILD_DIR}/profiledef.sh"
    touch "${BUILD_DIR}/profiledef.sh"
    cat << EOF > "${BUILD_DIR}/profiledef.sh"
    iso_name="${iso_name}"
    iso_version="${iso_version}"
    iso_label="${iso_label}"
    iso_publisher="${iso_publisher}"
    install_dir="${install_dir}"
    bootmodes=${bootmodes}
    arch="${arch}"
    pacman_conf="${pacman_conf}"
EOF
}

main() {
    check_root
    check_archiso
    create_build_dir
    profiledef_gen
    sudo mkarchiso -v "${BUILD_DIR}" command_iso
}

main
