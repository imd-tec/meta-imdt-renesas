#
# Copyright (c) 2024 IMD Technologies
#

FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://ap1302-sensor-rzv2h.conf \
    file://nxp_modules.conf \
"

do_install_append() {
    install -d ${D}${sysconfdir}/modprobe.d

    # Install modprobe config for AP1302
    install -m 0644 ${WORKDIR}/ap1302-sensor-rzv2h.conf ${D}${sysconfdir}/modprobe.d

    # Install modprobe for IW416 WiFi module
    install -m 0644 ${WORKDIR}/nxp_modules.conf ${D}${sysconfdir}/modprobe.d
}

FILES_${PN} += "${sysconfdir}/modprobe.d"
