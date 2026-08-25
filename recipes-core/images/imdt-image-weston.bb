require recipes-core/images/imdt-image-base.bb

REQUIRED_DISTRO_FEATURES = "wayland"

# Needed so rootfs-postcommands.bbclass sets default.target to graphical.target
# instead of multi-user.target; otherwise weston.service (WantedBy=graphical.target)
# never starts at boot even though it's enabled.
IMAGE_FEATURES += "weston"

IMAGE_INSTALL:append = " \
    libdrm \
    libdrm-tests \
"

IMAGE_INSTALL:append = "weston weston-init weston-examples gtk+3-demo"
IMAGE_INSTALL:append = "${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'weston-xwayland matchbox-terminal', '', d)}"
