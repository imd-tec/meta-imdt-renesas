#
# Copyright (c) 2024 IMD Technologies
#

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
	file://v4l2-init.sh \
"

SYSTEMD_AUTO_ENABLE = "disable"

do_install:append () {
	install -d ${D}/home/root
	install -m 0744 ${WORKDIR}/v4l2-init.sh ${D}/home/root/v4l2-init.sh
}

RDEPENDS:${PN} += "bash"
FILES:${PN} += "/home/root/v4l2-init.sh"
