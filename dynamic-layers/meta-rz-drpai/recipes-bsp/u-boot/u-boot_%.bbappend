FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
	file://0001-add-ether-setting.patch \
    file://0001-add_drpai_config_imdt.patch \
"
