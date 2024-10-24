# From meta-rz-drpai/recipes-core/images/core-image-%.bbappend
IMAGE_INSTALL_append = " \
    kernel-module-udmabuf \
    libjpeg-turbo-dev \
    opencv \
    opencv-dev \
"

TOOLCHAIN_TARGET_TASK_append = " drpai "

# From meta-imdt-renesas
IMAGE_INSTALL_append = " app-yolov2-cam "
