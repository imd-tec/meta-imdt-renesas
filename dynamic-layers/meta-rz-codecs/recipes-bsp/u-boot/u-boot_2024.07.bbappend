FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
UBOOT_CONFIG_FRAGMENT:append = " codec_conf_frag.cfg"
SRC_URI:append = " \
	file://codec_conf_frag.cfg \
"
SRC_URI:remove:rzv2h-evk = "file://0001_Add_OpenCVA_and_Codec.patch"

