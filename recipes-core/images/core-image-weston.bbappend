PREFERRED_VERSION_dhcpcd = "9.4.0"

IMAGE_INSTALL_append = " \
    dhcpcd \
    firmwared \
    hostapd \
    imdt-can-utils \
    imdt-ethernet-utils \
    imdt-pico-modem \
    imdt-wifi-utils \
    iw \
    kernel-module-nxp-wlan \
    libgpiod-tools \
    linux-firmware-ap1302 \
    linux-firmware-sdiouartiw416 \
    murata-binaries \
    udev-extraconf \
    wpa-supplicant \
    wireless-tools \
"
