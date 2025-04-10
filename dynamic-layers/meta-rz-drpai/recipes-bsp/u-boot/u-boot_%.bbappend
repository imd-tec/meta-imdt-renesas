FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
UBOOT_CONFIG_FRAGMENT += " drp_conf_frag.cfg"
SRC_URI_append = " \
    file://drp_conf_frag.cfg \
"
