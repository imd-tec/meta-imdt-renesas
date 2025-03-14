require conf/machine/include/rzv2h-common.inc
require conf/machine/include/cip-core.inc
DEFAULTTUNE ?= "cortexa55"

TUNE_CONF ?= "conf/machine/include/tune-cortexa55.inc"
require ${TUNE_CONF}

PREFERRED_PROVIDER_virtual/kernel="linux-renesas"
PREFERRED_VERSION_swupdate = "2021.11"
PREFERRED_VERSION_dhcpcd = "9.4.0"

# flash writer
EXTRA_IMAGEDEPENDS += " flash-writer"

# Add the HDMI and panel device tree files
KERNEL_DEVICETREE = " \
	renesas/imdt-v2-sbc-dsi-hdmi.dtb \
	renesas/imdt-v2-sbc-dsi-panel.dtb \
	renesas/${MACHINE}.dtb \
"
IMAGE_INSTALL_remove = " optee-client"

IMAGE_BOOT_FILES = " \
	u-boot-env.img \
"
WIC_INPUT_DEPENDS = "firmware-pack:do_deploy flash-writer:do_deploy"

KERNEL_DTC_FLAGS += " -@"
# Use the imdt-image wic file for the V2H and V2N
WKS_SUPPORT = "1"
WKS_DEFAULT_FILE = "imdt-image.wks"