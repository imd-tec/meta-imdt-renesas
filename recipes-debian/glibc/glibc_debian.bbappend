DPV = "2.28-10+deb10u4"
DPV_EPOCH = ""
REPACK_PV = "2.28"
PV = "2.28"

DEBIAN_SRC_URI = " \
    ${DEBIAN_SECURITY_UPDATE_MIRROR}/main/g/glibc/glibc_2.28-10+deb10u4.dsc;name=glibc_2.28-10+deb10u4.dsc \
    ${DEBIAN_SECURITY_UPDATE_MIRROR}/main/g/glibc/glibc_2.28.orig.tar.xz;name=glibc_2.28.orig.tar.xz \
    ${DEBIAN_SECURITY_UPDATE_MIRROR}/main/g/glibc/glibc_2.28-10+deb10u4.debian.tar.xz;name=glibc_2.28-10+deb10u4.debian.tar.xz \
"

SRC_URI[glibc_2.28-10+deb10u4.dsc.md5sum] = "b39dd7f7f54c6b7da3eefcd391470af2"
SRC_URI[glibc_2.28.orig.tar.xz.md5sum] = "2d78d5b080fbe4fefa2e1ccef9c39dbc"
SRC_URI[glibc_2.28-10+deb10u4.debian.tar.xz.md5sum] = "8ebb6ee80ba6a5e39eacc31c95994ef0"

SRC_URI[glibc_2.28-10+deb10u4.dsc.sha256sum] = "55e4ebd9a55755c84d42709b23f9b269f46b6a76f5040a0e05cfd323ba67f8af"
SRC_URI[glibc_2.28.orig.tar.xz.sha256sum] = "53d3c1c7bff0fb25d4c7874bf13435dc44a71fd7dd5ffc9bfdcb513cdfc36854"
SRC_URI[glibc_2.28-10+deb10u4.debian.tar.xz.sha256sum] = "dc287870d4b8cb5d1d175fa9b95e3a97d6b68699680b443ae7b2a1b89f0fe8fc"

