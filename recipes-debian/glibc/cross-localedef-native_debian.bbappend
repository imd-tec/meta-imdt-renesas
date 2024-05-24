DPV = "2.28-10+deb10u3"
DPV_EPOCH = ""
REPACK_PV = "2.28"
PV = "2.28"

DEBIAN_SRC_URI = " \
    ${DEBIAN_SECURITY_UPDATE_MIRROR}/main/g/glibc/glibc_2.28-10+deb10u3.dsc;name=glibc_2.28-10+deb10u3.dsc \
    ${DEBIAN_SECURITY_UPDATE_MIRROR}/main/g/glibc/glibc_2.28.orig.tar.xz;name=glibc_2.28.orig.tar.xz \
    ${DEBIAN_SECURITY_UPDATE_MIRROR}/main/g/glibc/glibc_2.28-10+deb10u3.debian.tar.xz;name=glibc_2.28-10+deb10u3.debian.tar.xz \
"

SRC_URI[glibc_2.28-10+deb10u3.dsc.md5sum] = "3cf31cd78b313daaf1f2729369e20096"
SRC_URI[glibc_2.28.orig.tar.xz.md5sum] = "2d78d5b080fbe4fefa2e1ccef9c39dbc"
SRC_URI[glibc_2.28-10+deb10u3.debian.tar.xz.md5sum] = "b3713583a27b26a1a6e051c3f9447782"

SRC_URI[glibc_2.28-10+deb10u3.dsc.sha256sum] = "731d162af297ab2f042e73b0910388a84214e48b68766ded409e6c391ca5e9c4"
SRC_URI[glibc_2.28.orig.tar.xz.sha256sum] = "53d3c1c7bff0fb25d4c7874bf13435dc44a71fd7dd5ffc9bfdcb513cdfc36854"
SRC_URI[glibc_2.28-10+deb10u3.debian.tar.xz.sha256sum] = "552ddba370dfe93ae9360b17ad4772b9f72b43223bf5e40a651797a2cbebadc2"

