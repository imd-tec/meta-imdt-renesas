FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append_imdt-v2h-sbc += "\
	file://add_drp1_dts.patch \
"
