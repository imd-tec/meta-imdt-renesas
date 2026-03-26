#
# Copyright (c) 2022 IMD Technologies
#

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
   file://hostapd.conf \
   file://hostapd.service \
"

SYSTEMD_AUTO_ENABLE:${PN} = "disable"

do_install:append() {
   install -d ${D}${sysconfdir}
   install -m 600 ${WORKDIR}/hostapd.conf ${D}${sysconfdir}

   install -d ${D}${systemd_system_unitdir}
   install -m 0644 ${WORKDIR}/hostapd.service ${D}${systemd_system_unitdir}
}
