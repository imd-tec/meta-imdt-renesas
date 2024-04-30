#
# Copyright (c) 2024 IMD Technologies
#

FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"

SRC_URI_append = " file://ap1302-sensor-rzv2h.conf "

do_install_append() {
    install -d ${D}${sysconfdir}/modprobe.d
    install -m 0644 ${WORKDIR}/ap1302-sensor-rzv2h.conf ${D}${sysconfdir}/modprobe.d
}

FILES_${PN} += "${sysconfdir}/modprobe.d"
