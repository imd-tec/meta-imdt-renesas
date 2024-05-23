#
# Copyright (c) 2024 IMD Technologies
#

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Proprietary;md5=0557f9d92cf58f2ccdd50f62f8ac0b28"

SRC_URI = "file://app-yolov2-cam-1.0-r0.aarch64.rpm;subdir=rpm"
PV = "1.0"

S = "${WORKDIR}/rpm"

RDEPENDS_${PN} = "mmngr-user-module mmngrbuf-user-module media-ctl libv4l libopencv-core libopencv-imgproc"

# Copy the contents of the RPM to the root filesystem
do_install_append() {
    cp -R ${S}/* ${D}
}

# Executables have already have their symbols stripped
INSANE_SKIP_${PN}_append = "already-stripped"

FILES_${PN} = "\
    /opt/imdt/pico-demos/app_yolov2_cam \
    /opt/imdt/pico-demos/yolov2_cam/* \
"
