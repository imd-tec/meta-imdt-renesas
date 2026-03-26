FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
	file://0001-Add-IMDT-UI-modification-for-web-client.patch \
	file://defconfig \
"

do_install:append:${MACHINE}() {
	echo "${MACHINE} 1.0" > ${D}/${sysconfdir}/hwrevision
}

FILES_${PN}:append:${MACHINE} = " \ 
	${sysconfdir}/hwrevision \ 
"