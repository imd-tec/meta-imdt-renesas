require recipes-core/images/imdt-image-core.bb

REQUIRED_DISTRO_FEATURES = "wayland"

IMAGE_INSTALL:append = " \
    libdrm \
    libdrm-tests \
"

IMAGE_INSTALL:append = "weston weston-init weston-examples gtk+3-demo"
IMAGE_INSTALL:append = "${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'weston-xwayland matchbox-terminal', '', d)}"
