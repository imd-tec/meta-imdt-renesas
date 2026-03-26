#
# Copyright (c) 2024 IMD Technologies
#

DESCRIPTION = "NXP IW416 WiFi stack for Murata 1XK module"

LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    kernel-module-nxp-wlan \
    linux-firmware-sdiouartiw416 \
    murata-binaries \
    udev-extraconf \
    iw \
    wpa-supplicant \
    hostapd \
    imdt-wifi-utils \
"
