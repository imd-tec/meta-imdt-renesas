require conf/machine/include/arm/armv8-2a/tune-cortexa55.inc
require conf/machine/include/rz-common.inc

SERIAL_CONSOLES ?= "115200;ttySC0"
PREFERRED_VERSION_trusted-firmware-a ?= "2.10%"
TFA_BOARD ?= "evk_1"
TFA_UBOOT ?= "1"
TFA_BUILD_TARGET ?= "bl2 bl31 fip"
BL2_BOOT_TARGET ?= "spi mmc esd"
EXTRA_IMAGEDEPENDS += " firmware-pack"

BL2_BASE_ADDR ?= "0x08103000"
BL2_ADJUST_VMA ?= "0x08101E00"
FIP_ADJUST_VMA ?= "0x0"

# U-Boot Configuration
PREFERRED_VERSION_u-boot = "2024.07%"

PREFERRED_PROVIDER_virtual/kernel = "linux-renesas"
PREFERRED_VERSION_linux-renesas ?= "6.1%"
# Kernel Configuration

# flash writer
EXTRA_IMAGEDEPENDS += " flash-writer"

# firmware pack
EXTRA_IMAGEDEPENDS += " firmware-pack"

# Add the HDMI and panel device tree files
KERNEL_DEVICETREE = " \
	renesas/imdt-v2-sbc-dsi-hdmi.dtbo \
	renesas/imdt-v2-sbc-dsi-panel.dtbo \
	renesas/${MACHINE}.dtb \
	renesas/imdt-v2-sbc-ar1335-csi2.dtbo \
	renesas/imdt-v2-sbc-ar1335-csi3.dtbo \
"
IMAGE_INSTALL:remove = " optee-client"

IMAGE_BOOT_FILES = " \
	u-boot-env.img \
"
KERNEL_DTC_FLAGS += " -@"

# Wic image
WKS_FILE = "imdt-image.wks"
do_image_wic[depends] += "firmware-pack:do_deploy"
# 4K alignment for fastboot support
IMAGE_ROOTFS_ALIGNMENT ?= "4"
