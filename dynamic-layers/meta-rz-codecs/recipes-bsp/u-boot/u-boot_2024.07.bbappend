FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
UBOOT_CONFIG_FRAGMENT:append = " codec_conf_frag.cfg"
SRC_URI:append = " \
	file://codec_conf_frag.cfg \
"
# Firmware loading is in our u-boot tree
SRC_URI:remove:rzv2h-evk = "file://0001_Add_OpenCVA_and_Codec.patch"
SRC_URI:remove:rzv2n-evk = "file://0001-Add-OpenCVA-and-Codec-for-V2N.patch"
