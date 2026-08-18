#
# Copyright (c) 2024 IMD Technologies
#

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# meta-rz-bsp's linux-firmware_%.bbappend hard-sets COMPATIBLE_MACHINE to
# "(smarc-rzg3l)", which would otherwise skip this recipe (and the
# linux-firmware-ap1302/-sdiouartiw416 packages below) on our machine.
COMPATIBLE_MACHINE:append = "|imdt-v2h-sbc"

SRC_URI:append = " \
    file://ap1302_ar1335_single_fw.bin \
    file://sduartiw416_combo.lf-6.12.20_2.0.0.bin \
"

do_install:append() {
    # AP1302 ISP firmware
    install -m 0644 ${WORKDIR}/ap1302_ar1335_single_fw.bin ${D}${nonarch_base_libdir}/firmware/ap1302_ar1335_single_fw.bin
    
    # Install NXP Connectivity IW416 firmware
    install -d ${D}${nonarch_base_libdir}/firmware/nxp
    install -m 0644 ${WORKDIR}/sduartiw416_combo.lf-6.12.20_2.0.0.bin ${D}${nonarch_base_libdir}/firmware/nxp/sdiouartiw416_combo_v0.bin
}

PACKAGES =+ "${PN}-ap1302 ${PN}-sdiouartiw416"
FILES:${PN}-ap1302 = "${nonarch_base_libdir}/firmware/ap1302_ar1335_single_fw.bin"
FILES:${PN}-sdiouartiw416 = "${nonarch_base_libdir}/firmware/nxp/sdiouartiw416_combo_v0.bin"
