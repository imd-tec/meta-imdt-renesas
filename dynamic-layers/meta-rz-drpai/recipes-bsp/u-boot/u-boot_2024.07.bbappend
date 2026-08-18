FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
UBOOT_CONFIG_FRAGMENT += " drp_conf_frag.cfg"
SRC_URI:append = " \
    file://drp_conf_frag.cfg \
"
SRC_URI:remove = "file://0001-add-ether-setting.patch"
