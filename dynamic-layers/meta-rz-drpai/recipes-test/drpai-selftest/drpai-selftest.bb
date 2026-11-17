SUMMARY = "DRP-AI self-test: run a prebuilt Renesas model on /dev/drpai0"
DESCRIPTION = "Runs Renesas's AI SDK fish classification model (the same \
build for RZ/V2H and RZ/V2N) on DRP-AI and checks the result. Used by the \
LAVA DRP-AI tests."
LICENSE = "MIT & Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
                    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

# Renesas AI SDK v6.20, Q04_fish_classification (Apache-2.0).
AISDK = "https://github.com/renesas-rz/rzv_ai_sdk/raw/def7d35d8195d7f981204e74d5fa4441367b59ba/Q04_fish_classification/exe_v2h"

SRC_URI = " \
    file://drpai-run.c \
    file://drpai-selftest \
    ${AISDK}/fish_classification_model/deploy.so;name=so;downloadfilename=drpai-fish-v620-deploy.so \
    ${AISDK}/fish_classification_model/deploy.json;name=json;downloadfilename=drpai-fish-v620-deploy.json \
    ${AISDK}/fish_classification_model/deploy.params;name=params;downloadfilename=drpai-fish-v620-deploy.params \
    ${AISDK}/Bangus.jpg;name=jpg;downloadfilename=drpai-fish-v620-Bangus.jpg \
"
SRC_URI[so.sha256sum] = "ae76dc70dfa79f03cd87421e29e53d83c075966957b87ef4d3b1c9bbd33adfe3"
SRC_URI[json.sha256sum] = "c20d3e69720e5b83f1e8cb9a504eeb8ae820a32dd9de2e849510a5ec5dc97a34"
SRC_URI[params.sha256sum] = "d6bca24d9d75183ed387d9cc8ad0d512056406a0053d98dc0ac8ab00568409e1"
SRC_URI[jpg.sha256sum] = "3b123cd5681380b970e29d710fecdf5fa1d123aa25d1afc25afb3c5a01f628c4"

S = "${WORKDIR}"

COMPATIBLE_MACHINE = "(r9a09g057|r9a09g056)"

DEPENDS = "rz-tvm-runtime mmngr-user-module mmngrbuf-user-module"
# rz-tvm-runtime differs per SoC
PACKAGE_ARCH = "${MACHINE_ARCH}"

do_compile() {
    ${CC} ${CFLAGS} ${LDFLAGS} -o drpai-run drpai-run.c -ltvm_runtime -lm
}

do_install() {
    install -D -m 0755 drpai-run ${D}${bindir}/drpai-run
    install -D -m 0755 drpai-selftest ${D}${bindir}/drpai-selftest
    install -d ${D}${datadir}/drpai-selftest/model
    install -m 0644 drpai-fish-v620-deploy.so ${D}${datadir}/drpai-selftest/model/deploy.so
    install -m 0644 drpai-fish-v620-deploy.json ${D}${datadir}/drpai-selftest/model/deploy.json
    install -m 0644 drpai-fish-v620-deploy.params ${D}${datadir}/drpai-selftest/model/deploy.params
    install -m 0644 drpai-fish-v620-Bangus.jpg ${D}${datadir}/drpai-selftest/Bangus.jpg
}

# deploy.so is a prebuilt model library, loaded with dlopen by the TVM runtime.
INSANE_SKIP:${PN} += "already-stripped arch"

RDEPENDS:${PN} = "rz-tvm-runtime python3-core python3-numpy python3-opencv"
