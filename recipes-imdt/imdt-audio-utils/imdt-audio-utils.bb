#
# Copyright (c) 2024 IMD Technologies
#

DESCRIPTION = "Utilities for controlling and configuring the SBC audio"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PV = "1.0.0"

SRC_URI = " \
    file://mozart.wav \
    file://audio-ctl.sh \
"

do_install() {
    # install audio files and scripts
    install -d ${D}/opt/imdt/audio/
    install -m 0644 ${WORKDIR}/mozart.wav ${D}/opt/imdt/audio/
    install -m 0744 ${WORKDIR}/audio-ctl.sh ${D}/opt/imdt/audio/
}

FILES_${PN} += " \
    /opt/imdt/audio/ \
"

RDEPENDS_${PN} += "alsa-utils alsa-state bash"
