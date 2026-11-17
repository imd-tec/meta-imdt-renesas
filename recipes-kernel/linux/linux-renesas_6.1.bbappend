FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

KERNEL_URL = "git://github.com/imd-tec/renesas-rz-linux-cip.git"
KERNEL_PROTOCOL = "https"
KERNEL_BRANCH = "rzv2-6.1.y"
KERNEL_REV = "e33299f67d98f3150925b2a3257576b6a906af09"
PV = "6.1.141"

BB_DONT_CACHE = "1"

SRC_URI = "${KERNEL_URL};protocol=${KERNEL_PROTOCOL};branch=${KERNEL_BRANCH}"
SRCREV = "${KERNEL_REV}"

INSANE_SKIP += "buildpaths"

# must remove the following drpai patch as it patches lines that have been removed since the patch was generated.
SRC_URI:remove = "file://0004-set-cru-amnaxiattr-axilen.patch"

# Enable the Panfrost GPU driver (imdt.cfg) and the gpu DT node on imdt-v2h-sbc.
SRC_URI += "file://0001-arm64-imdt-v2h-sbc-enable-Panfrost-GPU-driver-and-DT.patch"

do_kernel_configme:append() {
    merge_config.sh -O ${B} -m ${B}/.config \
        ${S}/arch/arm64/configs/imdt.cfg
}

