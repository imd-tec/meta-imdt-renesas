FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://0001-ckwart-use-ANSI-prototype-for-main.patch \
"
