#
# Copyright (c) 2024 IMD Technologies
#

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://19-eth0.network.disabled \
    file://19-eth1.network.disabled \
    file://19-wired.network \
    file://21-ap.network.disabled \
    file://25-wlan.network \
"

do_install_append() {
    install -d ${D}${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/19-eth0.network.disabled ${D}${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/19-eth1.network.disabled ${D}${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/19-wired.network ${D}${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/21-ap.network.disabled ${D}${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/25-wlan.network ${D}${systemd_unitdir}/network
}

FILES_${PN} += "${systemd_unitdir}/network"
