#
# Copyright (c) 2022 IMD Technologies
#

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://imdt-libubootenv-config.service \
    file://generate-fwenv-config.sh \
"

inherit systemd

do_install_append () {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/imdt-libubootenv-config.service ${D}${systemd_system_unitdir}

    install -d ${D}/opt/imdt/libubootenv
    install -m 0744 ${WORKDIR}/generate-fwenv-config.sh ${D}/opt/imdt/libubootenv
}

RDEPENDS_${PN}_append = " bash"

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_${PN} = "imdt-libubootenv-config.service"

FILES_${PN} += " \
    /opt/imdt/libubootenv/generate-fwenv-config.sh \
"
RRECOMMENDS_${PN}-bin_append_class-target = ""
