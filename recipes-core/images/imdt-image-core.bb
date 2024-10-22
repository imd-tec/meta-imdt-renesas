DESCRIPTION = "This is the core image with IMDT's demo application."

IMAGE_FEATURES += "splash package-management ssh-server-dropbear hwcodecs"

LICENSE = "MIT"

inherit core-image features_check

SDKIMAGE_FEATURES_append = " \
     dev-pkgs \
     staticdev-pkgs \
"

IMAGE_INSTALL = "packagegroup-core-boot ${CORE_IMAGE_EXTRA_INSTALL}"
IMAGE_INSTALL_append = " \
    ${@oe.utils.conditional('BBFILE_COLLECTIONS_rz-drpai', '1', ' app-yolov2-cam', '', d)} \
    bash \
    bonnie++ \
    busybox \
    can-utils \
    coreutils \
    devmem2 \
    dhcpcd \
    dosfstools \
    ethtool \
    firmwared \
    hostapd \
    i2c-tools \
    imdt-audio-utils \
    imdt-can-utils \
    imdt-ethernet-utils \
    imdt-pico-demos \
    imdt-pico-modem \
    imdt-wifi-utils \
    init-ifupdown \
    iperf3 \
    iproute2 \
    iw \
    kernel-devicetree \
    kernel-image \
    kernel-modules \
    kernel-module-nxp-wlan \
    kernel-module-uvcvideo \
    libgpiod-tools \
    libjpeg-turbo-dev \
    libusb1 \
    linux-firmware-ap1302 \
    linux-firmware-sdiouartiw416 \
    memtester \
    minicom \
    mmc-utils \
    mtd-utils \
    murata-binaries \
    nano \
    ${@oe.utils.conditional('BBFILE_COLLECTIONS_rz-opencva', '1', 'oca', '', d)} \
    packagegroup-gstreamer1.0-plugins \  
    packagegroup-multimedia-kernel-modules \
    packagegroup-multimedia-libs \
    pciutils \
    swupdate \
    swupdate-progress \
    swupdate-www \
    tcf-agent \
    udev-extraconf \
    u-boot-fw-utils \
    usbutils \
    util-linux \
    v4l2-init \
    v4l-utils \
    watchdog \
    wireless-tools \
    wpa-supplicant \
    yavta \
    opencv \
    opencv-dev \
"

# Environment setup, support building kernel modules with kernel src in SDK
export KERNELSRC="$SDKTARGETSYSROOT/usr/src/kernel"
export KERNELDIR="$SDKTARGETSYSROOT/usr/src/kernel"
export HOST_EXTRACFLAGS="-I${OECORE_NATIVE_SYSROOT}/usr/include/ -L${OECORE_NATIVE_SYSROOT}/usr/lib"

# Force remake wic image if its inputs were changed (WIC_INPUT_DEPENDS are defined in each machine conf)
# Note that environment variable WKS_FILE_DEPENDS can be used here, but it makes do_rootfs rerun as well
do_image_wic[depends] += "${WIC_INPUT_DEPENDS}"

# Default WKS is eMMC, except rzg2l devices which can support eSD boot
WKS_DEFAULT_FILE = "rz-image-bootpart-mmc.wks"
#WKS_DEFAULT_FILE_rzg2l = "rz-image-bootpart-esd.wks"
#WKS_DEFAULT_FILE_smarc-rzg2l = "rz-image-bootpart-esd-pmic.wks"
WKS_FILE ?= "${@oe.utils.conditional("WKS_SUPPORT", "1", "${WKS_DEFAULT_FILE}", "", d)}"
