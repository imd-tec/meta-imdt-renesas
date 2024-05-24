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
    app-yolov2-cam \
    bash \
    bonnie++ \
    busybox \
    can-utils \
    coreutils \
    dhcpcd \
    dosfstools \
    ethtool \
    firmwared \
    hostapd \
    i2c-tools \
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
    kernel-module-udmabuf \
    kernel-module-uvcvideo \
    libgpiod-tools \
    libjpeg-turbo-dev \
    libusb1 \
    linux-firmware-ap1302 \
    linux-firmware-sdiouartiw416 \
    memtester \
    minicom \
    mtd-utils \
    murata-binaries \
    nano \
    pciutils \
    tcf-agent \
    udev-extraconf \
    usbutils \
    util-linux \
    v4l2-init \
    v4l-utils \
    watchdog \
    wireless-tools \
    wpa-supplicant \
    yavta \
"

# Environment setup, support building kernel modules with kernel src in SDK
export KERNELSRC="$SDKTARGETSYSROOT/usr/src/kernel"
export KERNELDIR="$SDKTARGETSYSROOT/usr/src/kernel"
export HOST_EXTRACFLAGS="-I${OECORE_NATIVE_SYSROOT}/usr/include/ -L${OECORE_NATIVE_SYSROOT}/usr/lib"

# Force remake wic image if its inputs were changed (WIC_INPUT_DEPENDS are defined in each machine conf)
# Note that environment variable WKS_FILE_DEPENDS can be used here, but it makes do_rootfs rerun as well
do_image_wic[depends] += "${WIC_INPUT_DEPENDS}"

PREFERRED_VERSION_dhcpcd = "9.4.0"

# Default WKS is eMMC, except rzg2l devices which can support eSD boot
WKS_DEFAULT_FILE = "rz-image-bootpart-mmc.wks"
#WKS_DEFAULT_FILE_rzg2l = "rz-image-bootpart-esd.wks"
#WKS_DEFAULT_FILE_smarc-rzg2l = "rz-image-bootpart-esd-pmic.wks"
WKS_FILE ?= "${@oe.utils.conditional("WKS_SUPPORT", "1", "${WKS_DEFAULT_FILE}", "", d)}"

