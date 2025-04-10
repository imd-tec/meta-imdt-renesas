FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
UBOOT_CONFIG_FRAGMENT_append += "codec_conf_frag.cfg"
SRC_URI_append = " \
	file://codec_conf_frag.cfg \
"
