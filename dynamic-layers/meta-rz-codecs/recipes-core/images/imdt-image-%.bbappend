# from meta-rz-codecs/recipes-core/images/core-image-%.bbappend
# extend packages
IMAGE_INSTALL_append = " \
    codec \
"

TOOLCHAIN_TARGET_TASK_append = " drp "
