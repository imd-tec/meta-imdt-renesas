FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
UBOOT_CONFIG_FRAGMENT_imdt-v2h-sbc += " codec_conf_frag.cfg"
SRC_URI_append_imdt-v2h-sbc = " \
	file://codec_conf_frag.cfg \
"
