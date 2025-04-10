FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append += "\
	file://add_drp1_v2h_dts.patch \
	file://add_drp1_v2n_dts.patch \
"
