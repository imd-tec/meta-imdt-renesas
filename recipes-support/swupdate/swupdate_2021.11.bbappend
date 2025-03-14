FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
	file://0001-Rebrand-the-SWUpdate-UI.patch \
	file://defconfig \
"

do_install_append_${MACHINE}() {
	echo "${MACHINE}" > ${D}/${sysconfdir}/hwrevision
}

FILES_${PN}_append_${MACHINE} = " \ 
	${sysconfdir}/hwrevision \ 
"