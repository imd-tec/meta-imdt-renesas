# from meta-rz-codecs/recipes-core/images/core-image-%.bbappend
# extend packages
IMAGE_INSTALL:append = " \
    drp-fw \
"

TOOLCHAIN_TARGET_TASK:append = " drp "
