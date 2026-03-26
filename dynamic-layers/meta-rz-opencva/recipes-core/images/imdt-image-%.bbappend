#From meta-rz-opencva/recipes-core/images/core-image-%.bbappend
# extend packages
IMAGE_INSTALL:append = " \
    opencv \
    oca \
"

TOOLCHAIN_TARGET_TASK:append = " drp "
