# Copyright (c) 2024 IMD Technologies

DESCRIPTION = "Create a SWUpdate image for the IMDT-V2H-SBC "

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Proprietary;md5=0557f9d92cf58f2ccdd50f62f8ac0b28"

inherit swupdate

SRC_URI_${MACHINE} = " \
    file://sw-description \
    file://update.sh \
"

# Dependencies to build before creating the SWUpdate image
IMAGE_DEPENDS = "imdt-image-weston"

SWUPDATE_IMAGES_${MACHINE}= " \
    bl2_bp_spi-${MACHINE}.bin \
    fip-${MACHINE}.bin \
    imdt-image-weston-${MACHINE} \
"

SWUPDATE_IMAGES_append_imdt-v2h-sbc = " \
    bl2_bp_emmc-${MACHINE}.bin \
"

SWUPDATE_IMAGES_append_imdt-v2n-sbc = " \
    bl2_bp_mmc-${MACHINE}.bin \
"

SDIMG_ROOTFS_TYPE = "ext4.gz"
# SWUpdate requires that the root filesystem be compressed using GZip
SWUPDATE_IMAGES_FSTYPES[imdt-image-weston-imdt-v2h-sbc] = ".tar.gz"
SWUPDATE_IMAGES_FSTYPES[imdt-image-weston-imdt-v2n-sbc] = ".tar.gz"
