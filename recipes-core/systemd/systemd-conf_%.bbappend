#
# Copyright (c) 2024 IMD Technologies
#

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://19-end0.network.disabled \
    file://19-end1.network.disabled \
    file://19-wired.network \
    file://21-ap.network.disabled \
    file://25-wlan.network \
"

do_install:append() {
    install -d ${D}${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/19-end0.network.disabled ${D}${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/19-end1.network.disabled ${D}${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/19-wired.network ${D}${systemd_unitdir}/network
    # Default state: both AP and STA disabled (scripts enable on demand)
    install -m 0644 ${WORKDIR}/21-ap.network.disabled ${D}${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/25-wlan.network ${D}${systemd_unitdir}/network/25-wlan.network.disabled
}

FILES:${PN} += "${systemd_unitdir}/network"
