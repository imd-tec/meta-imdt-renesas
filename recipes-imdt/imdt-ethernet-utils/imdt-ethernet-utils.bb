#
# Copyright (c) 2023 IMD Technologies
#

DESCRIPTION = "Utilities for controlling and configuring the Pico-e ethernet adapter"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PV = "1.0.0"

SRC_URI = " \
    file://ethernet-lib.sh \
    file://get-eth-mode.sh \
    file://set-eth-mode.sh \
"

do_install() {
    install -d ${D}/opt/imdt/ethernet
    install -m 0744 ${WORKDIR}/ethernet-lib.sh ${D}/opt/imdt/ethernet
    install -m 0744 ${WORKDIR}/get-eth-mode.sh ${D}/opt/imdt/ethernet
    install -m 0744 ${WORKDIR}/set-eth-mode.sh ${D}/opt/imdt/ethernet
}

FILES_${PN} += " \
    /opt/imdt/ethernet/ \
"

RDEPENDS_${PN} += "bash"
