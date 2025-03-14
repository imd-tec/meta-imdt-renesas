FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
UBOOT_CONFIG_FRAGMENT += " drp_conf_frag.cfg"
SRC_URI_append = " \
    file://0001-add-ether-setting.patch \
    file://drp_conf_frag.cfg \
"
