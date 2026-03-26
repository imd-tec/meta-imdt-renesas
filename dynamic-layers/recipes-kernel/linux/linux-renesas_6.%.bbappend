FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:imdt-v2n-sbc = " \
	file://0001-add-drp1-to-v2n.patch \
"

SRC_URI:append:imdt-v2h-sbc = " \
	file://0002-add-drp1-to-v2h.patch \
"