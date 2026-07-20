FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI:append = " file://0001-android-tools-conf-configfs-replace-fixed-sleep-with-UDC-wait-loop.patch \
                   file://0002-adb-race.patch \
                   file://0003-android-gadget-start-wait-for-FunctionFS-ep1-before-.patch \
"
