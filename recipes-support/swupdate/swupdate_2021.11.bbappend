FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
	file://0001-Rebrand-the-SWUpdate-UI.patch \
	file://defconfig \
"
do_install_append_imdt-v2c-sbc() {
	echo "v2h-sbc 1.0" > ${D}/${sysconfdir}/hwrevision
}
FILES_${PN}_append_imdt-v2c-sbc = " \ 
	${sysconfdir}/hwrevision \ 
"

