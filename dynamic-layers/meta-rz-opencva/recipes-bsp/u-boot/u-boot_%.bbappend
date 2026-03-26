FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
UBOOT_CONFIG_FRAGMENT:append = "opencva_conf_frag.cfg"
SRC_URI:append = " \
	file://opencva_conf_frag.cfg \
"
