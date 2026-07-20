DESCRIPTION = "IMDT base image for Renesas RZ platforms."

python () {
    if bb.utils.contains('DISTRO_FEATURES', 'imdt-isp', True, False, d):
        bb.warn("imdt-image-base is being built with 'imdt-isp' in DISTRO_FEATURES. " \
                "The kernel will include ISP modules. Use imdt-image-isp instead.")
}

IMAGE_FEATURES += "splash package-management ssh-server-dropbear hwcodecs"

# Enable ADB over USB. USB_DEBUGGING_ENABLED triggers android_tools_enable_devmode
# which creates /etc/usb-debugging-enabled, required by the adbd service condition.
USB_DEBUGGING_ENABLED = "1"

LICENSE = "MIT"

inherit core-image

SDKIMAGE_FEATURES:append = " dev-pkgs staticdev-pkgs"

IMAGE_INSTALL:append = " \
    bash \
    clinfo \
    coreutils \
    devmem2 \
    firmwared \
    kernel-modules \
    libgpiod-tools \
    libgomp \
    libjpeg-turbo-dev \
    libsdl2 \
    libusb1 \
    linux-firmware-ap1302 \
    mmc-utils \
    nano \
    opencv \
    opencv-dev \
    packagegroup-gstreamer1.0-plugins \
    packagegroup-imdt \
    packagegroup-imdt-wifi \
    pciutils \
    swupdate \
    swupdate-progress \
    swupdate-www \
    u-boot-fw-utils \
    android-tools-adbd \
    android-tools-conf-configfs \
    usbutils \
    util-linux \
    wireless-regdb-static \
"

# Environment setup, support building kernel modules with kernel src in SDK
export KERNELSRC="$SDKTARGETSYSROOT/usr/src/kernel"
export KERNELDIR="$SDKTARGETSYSROOT/usr/src/kernel"
export HOST_EXTRACFLAGS="-I${OECORE_NATIVE_SYSROOT}/usr/include/ -L${OECORE_NATIVE_SYSROOT}/usr/lib"

# Force remake wic image if its inputs were changed (WIC_INPUT_DEPENDS are defined in each machine conf)
# Note that environment variable WKS_FILE_DEPENDS can be used here, but it makes do_rootfs rerun as well
#do_image_wic[depends] += "${WIC_INPUT_DEPENDS}"

# Default WKS is eMMC, except rzg2l devices which can support eSD boot
WKS_DEFAULT_FILE ?= "rz-image-bootpart-mmc.wks"
WKS_FILE ?= "${@oe.utils.conditional("WKS_SUPPORT", "1", "${WKS_DEFAULT_FILE}", "", d)}"
