FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append += "\
	file://drpai0_patch_v2h.patch \
	file://modify_mem_v2n_dts.patch \
	file://drpai0_patch_v2n.patch \ 
"
