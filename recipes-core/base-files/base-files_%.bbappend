do_install:append() {
    echo "${DISTRO_NAME} ${DISTRO_VERSION}" > ${D}${sysconfdir}/issue
}

do_install[vardeps] += "DISTRO_VERSION DISTRO_NAME"
