PREFERRED_VERSION_dhcpcd = "9.4.0"

IMAGE_INSTALL_append = " \
    app-yolov2-cam \
    dhcpcd \
    firmwared \
    hostapd \
    imdt-can-utils \
    imdt-ethernet-utils \
    imdt-pico-modem \
    imdt-pico-demos \
    imdt-wifi-utils \
    iw \
    kernel-modules \
    kernel-module-nxp-wlan \
    kernel-module-uvcvideo \
    libgpiod-tools \
    linux-firmware-ap1302 \
    linux-firmware-sdiouartiw416 \
    murata-binaries \
    udev-extraconf \
    wpa-supplicant \
    wireless-tools \
"
