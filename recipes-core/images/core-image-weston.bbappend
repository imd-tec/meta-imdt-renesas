PREFERRED_VERSION_dhcpcd = "9.4.0"

IMAGE_INSTALL_append = " \
    imdt-can-utils \
    libgpiod-tools \
    imdt-pico-modem \
    dhcpcd \
"
