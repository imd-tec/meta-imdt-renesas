#
# Copyright (c) 2024 IMD Technologies
#

DESCRIPTION = "Utilities for controlling and configuring the CAN interface"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PV = "1.0.0"

SRC_URI = " \
    file://start-can.sh \
    file://stop-can.sh \
"

do_install() {
    install -d ${D}/opt/imdt/can
    install -m 0744 ${WORKDIR}/start-can.sh ${D}/opt/imdt/can
    install -m 0744 ${WORKDIR}/stop-can.sh ${D}/opt/imdt/can
}

FILES_${PN} += " \
    /opt/imdt/can/ \
"

RDEPENDS_${PN} += "bash"
