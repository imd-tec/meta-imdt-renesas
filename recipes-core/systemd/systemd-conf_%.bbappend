#
# Copyright (c) 2024 IMD Technologies
#

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://80-eth0.network \
    file://80-eth1.network \
    file://80-wired.network \
"

do_install_append() {
    install -d ${D}${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/80-eth0.network ${D}${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/80-eth1.network ${D}${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/80-wired.network ${D}${systemd_unitdir}/network
}

FILES_${PN} += "${systemd_unitdir}/network"
