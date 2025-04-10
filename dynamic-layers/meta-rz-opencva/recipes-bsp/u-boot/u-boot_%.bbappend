FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
UBOOT_CONFIG_FRAGMENT_append += "opencva_conf_frag.cfg"
SRC_URI_append = " \
	file://opencva_conf_frag.cfg \
"
