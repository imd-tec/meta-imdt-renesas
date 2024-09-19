# Copyright (c) 2024 IMD Technologies

DESCRIPTION = "Create a SWUpdate image for the IMDT-V2H-SBC "

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Proprietary;md5=0557f9d92cf58f2ccdd50f62f8ac0b28"

inherit swupdate

SRC_URI_imdt-v2h-sbc = " \
    file://sw-description \
    file://update.sh \
"

# Dependencies to build before creating the SWUpdate image
IMAGE_DEPENDS = "imdt-image-weston"

SWUPDATE_IMAGES_imdt-v2h-sbc = " \
    Image \
    imdt-v2h-sbc.dtb \
    bl2_bp_spi-imdt-v2h-sbc.bin \
    bl2_bp_emmc-imdt-v2h-sbc.bin \
    fip-imdt-v2h-sbc.bin \
    imdt-image-weston-imdt-v2h-sbc \
"
SDIMG_ROOTFS_TYPE = "ext4.gz"
# SWUpdate requires that the root filesystem be compressed using GZip
SWUPDATE_IMAGES_FSTYPES[imdt-image-weston-imdt-v2h-sbc] = ".tar.gz"
