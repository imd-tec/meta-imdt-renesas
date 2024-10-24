#From meta-rz-opencva/recipes-core/images/core-image-%.bbappend
# extend packages
IMAGE_INSTALL_append = " \
    opencv \
    oca \
"

TOOLCHAIN_TARGET_TASK_append = " drp "
