#
# Copyright (c) 2024 IMD Technologies
#

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://ap1302_ar1335_single_fw.bin \
"

do_install_append() {
    # AP1302 ISP firmware
    install -m 0644 ${WORKDIR}/ap1302_ar1335_single_fw.bin ${D}/lib/firmware/ap1302_ar1335_single_fw.bin
}

PACKAGES =+ "${PN}-ap1302"

FILES_${PN}-ap1302 = " \
    ${nonarch_base_libdir}/firmware/ap1302_ar1335_single_fw.bin \
"
