require recipes-core/images/imdt-image-core.bb

REQUIRED_DISTRO_FEATURES = "wayland"

IMAGE_INSTALL_append = " \
    libdrm \
    libdrm-tests \
"

CORE_IMAGE_BASE_INSTALL += "weston weston-init weston-examples gtk+3-demo clutter-1.0-examples"
CORE_IMAGE_BASE_INSTALL += "${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'weston-xwayland matchbox-terminal', '', d)}"
