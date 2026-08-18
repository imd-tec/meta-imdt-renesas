SRC_URI = "git://github.com/imd-tec/renesas-u-boot-cip.git;protocol=https;branch=imdt-v2024.07"
SRCREV = "e1add1386c451c760548c144681ce99af667ea62"
inherit uboot-config uboot-extlinux-config uboot-sign deploy cml1 python3native

DEPENDS += "kern-tools-native u-boot-tools-native"

UBOOT_ENV_SUFFIX = "img"
UBOOT_ENV = "u-boot-env"
COMPATIBLE_MACHINE:append = "|imdt-v2"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://overlays.cfg \
"

# Default name of u-boot initial env, but enable individual recipes to change
# this value.
UBOOT_INITIAL_ENV ?= "${PN}-initial-env"

do_configure () {
    if [ -n "${UBOOT_CONFIG}" ]; then
        unset i j
        for config in ${UBOOT_MACHINE}; do
            i=$(expr $i + 1);
            for type in ${UBOOT_CONFIG}; do
                j=$(expr $j + 1);
                if [ $j -eq $i ]; then
                    oe_runmake -C ${S} O=${B}/${config} ${config}
                    if [ -n "${@' '.join(find_cfgs(d))}" ]; then
                        merge_config.sh -m -O ${B}/${config} ${B}/${config}/.config ${@" ".join(find_cfgs(d))}
                        oe_runmake -C ${S} O=${B}/${config} oldconfig
                    fi
                fi
            done
            unset j
        done
        unset i
        DEVTOOL_DISABLE_MENUCONFIG=true
    else
        if [ -n "${UBOOT_MACHINE}" ]; then
            oe_runmake -C ${S} O=${B} ${UBOOT_MACHINE}
        else
            oe_runmake -C ${S} O=${B} oldconfig
        fi
        merge_config.sh -m .config ${@" ".join(find_cfgs(d))}
        cml1_do_configure
    fi
}

do_compile () {

    # Ensure mkenvimage is in the PATH
    export PATH="${STAGING_BINDIR_NATIVE}:${PATH}"

    if [ "${@bb.utils.filter('DISTRO_FEATURES', 'ld-is-gold', d)}" ]; then
        sed -i 's/$(CROSS_COMPILE)ld$/$(CROSS_COMPILE)ld.bfd/g' ${S}/config.mk
    fi

    unset LDFLAGS
    unset CFLAGS
    unset CPPFLAGS
   

    if [ ! -e ${B}/.scmversion -a ! -e ${S}/.scmversion ]
    then
        echo ${UBOOT_LOCALVERSION} > ${B}/.scmversion
        echo ${UBOOT_LOCALVERSION} > ${S}/.scmversion
    fi

    if [ -n "${UBOOT_CONFIG}" ]
    then
        unset i j k
        for config in ${UBOOT_MACHINE}; do
            i=$(expr $i + 1);
            for type in ${UBOOT_CONFIG}; do
                j=$(expr $j + 1);
                if [ $j -eq $i ]
                then
                    oe_runmake -C ${S} O=${B}/${config} ${UBOOT_MAKE_TARGET}
                    for binary in ${UBOOT_BINARIES}; do
                        k=$(expr $k + 1);
                        if [ $k -eq $i ]; then
                            cp ${B}/${config}/${binary} ${B}/${config}/u-boot-${type}.${UBOOT_SUFFIX}
                        fi
                    done

                    # Generate the uboot-initial-env
                    if [ -n "${UBOOT_INITIAL_ENV}" ]; then
                        oe_runmake -C ${S} O=${B}/${config} u-boot-initial-env
                        ENV_FILE="${B}/${config}/u-boot-initial-env-${type}"
                        cp ${B}/${config}/u-boot-initial-env ${ENV_FILE}
                    fi

                    unset k
                fi
            done
            unset  j
        done
        unset  i
    else
        oe_runmake -C ${S} O=${B} ${UBOOT_MAKE_TARGET}
        
        # Generate the uboot-initial-env
        if [ -n "${UBOOT_INITIAL_ENV}" ]; then
            oe_runmake -C ${S} O=${B} u-boot-initial-env
            ENV_FILE="${B}/u-boot-initial-env"
        fi
    fi

    # Generate the environment image using mkenvimage
    if [ -n "${ENV_FILE}" -a -f "${ENV_FILE}" ]; then
        echo "Generating U-Boot environment image..."
        mkenvimage -s 0x20000 -o ${B}/${UBOOT_ENV_BINARY} ${ENV_FILE}
    fi
}

# ${PN}-env package, RPROVIDES, ALLOW_EMPTY, FILES, and RDEPENDS are already
# defined in poky's u-boot.inc — no need to redefine them here.

SYSROOT_DIRS_rzg2l = "/boot"

do_install () {
    if [ -n "${UBOOT_CONFIG}" ]
    then
        for config in ${UBOOT_MACHINE}; do
            i=$(expr $i + 1);
            for type in ${UBOOT_CONFIG}; do
                j=$(expr $j + 1);
                if [ $j -eq $i ]
                then
                    install -d ${D}/boot
                    install -m 644 ${B}/${config}/u-boot-${type}.${UBOOT_SUFFIX} ${D}/boot/u-boot-${type}-${PV}-${PR}.${UBOOT_SUFFIX}
                    ln -sf u-boot-${type}-${PV}-${PR}.${UBOOT_SUFFIX} ${D}/boot/${UBOOT_BINARY}-${type}
                    ln -sf u-boot-${type}-${PV}-${PR}.${UBOOT_SUFFIX} ${D}/boot/${UBOOT_BINARY}

                    # Install the uboot-initial-env
                    if [ -n "${UBOOT_INITIAL_ENV}" ]; then
                        install -D -m 644 ${B}/${config}/u-boot-initial-env-${type} ${D}/${sysconfdir}/${UBOOT_INITIAL_ENV}-${MACHINE}-${type}-${PV}-${PR}
                        ln -sf ${UBOOT_INITIAL_ENV}-${MACHINE}-${type}-${PV}-${PR} ${D}/${sysconfdir}/${UBOOT_INITIAL_ENV}-${MACHINE}-${type}
                        ln -sf ${UBOOT_INITIAL_ENV}-${MACHINE}-${type}-${PV}-${PR} ${D}/${sysconfdir}/${UBOOT_INITIAL_ENV}-${type}
                        ln -sf ${UBOOT_INITIAL_ENV}-${MACHINE}-${type}-${PV}-${PR} ${D}/${sysconfdir}/${UBOOT_INITIAL_ENV}
                    fi
                fi
            done
            unset  j
        done
        unset  i
    else
        install -d ${D}/boot
        install -m 644 ${B}/${UBOOT_BINARY} ${D}/boot/${UBOOT_IMAGE}
        ln -sf ${UBOOT_IMAGE} ${D}/boot/${UBOOT_BINARY}

        # Install the uboot-initial-env
        if [ -n "${UBOOT_INITIAL_ENV}" ]; then
            install -D -m 644 ${B}/u-boot-initial-env ${D}/${sysconfdir}/${UBOOT_INITIAL_ENV}-${MACHINE}-${PV}-${PR}
            ln -sf ${UBOOT_INITIAL_ENV}-${MACHINE}-${PV}-${PR} ${D}/${sysconfdir}/${UBOOT_INITIAL_ENV}-${MACHINE}
            ln -sf ${UBOOT_INITIAL_ENV}-${MACHINE}-${PV}-${PR} ${D}/${sysconfdir}/${UBOOT_INITIAL_ENV}
        fi
    fi

    if [ -n "${UBOOT_ELF}" ]
    then
        if [ -n "${UBOOT_CONFIG}" ]
        then
            for config in ${UBOOT_MACHINE}; do
                i=$(expr $i + 1);
                for type in ${UBOOT_CONFIG}; do
                    j=$(expr $j + 1);
                    if [ $j -eq $i ]
                    then
                        install -m 644 ${B}/${config}/${UBOOT_ELF} ${D}/boot/u-boot-${type}-${PV}-${PR}.${UBOOT_ELF_SUFFIX}
                        ln -sf u-boot-${type}-${PV}-${PR}.${UBOOT_ELF_SUFFIX} ${D}/boot/${UBOOT_BINARY}-${type}
                        ln -sf u-boot-${type}-${PV}-${PR}.${UBOOT_ELF_SUFFIX} ${D}/boot/${UBOOT_BINARY}
                    fi
                done
                unset j
            done
            unset i
        else
            install -m 644 ${B}/${UBOOT_ELF} ${D}/boot/${UBOOT_ELF_IMAGE}
            ln -sf ${UBOOT_ELF_IMAGE} ${D}/boot/${UBOOT_ELF_BINARY}
        fi
    fi

    if [ -e ${WORKDIR}/fw_env.config ] ; then
        install -d ${D}${sysconfdir}
        install -m 644 ${WORKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
    fi

    if [ -n "${SPL_BINARY}" ]
    then
        if [ -n "${UBOOT_CONFIG}" ]
        then
            for config in ${UBOOT_MACHINE}; do
                i=$(expr $i + 1);
                for type in ${UBOOT_CONFIG}; do
                    j=$(expr $j + 1);
                    if [ $j -eq $i ]
                    then
                         install -m 644 ${B}/${config}/${SPL_BINARY} ${D}/boot/${SPL_IMAGE}-${type}-${PV}-${PR}
                         ln -sf ${SPL_IMAGE}-${type}-${PV}-${PR} ${D}/boot/${SPL_BINARYNAME}-${type}
                         ln -sf ${SPL_IMAGE}-${type}-${PV}-${PR} ${D}/boot/${SPL_BINARYNAME}
                    fi
                done
                unset  j
            done
            unset  i
        else
            install -m 644 ${B}/${SPL_BINARY} ${D}/boot/${SPL_IMAGE}
            ln -sf ${SPL_IMAGE} ${D}/boot/${SPL_BINARYNAME}
        fi
    fi

    if [ -n "${UBOOT_ENV}" ]
    then
        install -m 644 ${B}/${UBOOT_ENV_BINARY} ${D}/boot/${UBOOT_ENV_IMAGE}
        ln -sf ${UBOOT_ENV_IMAGE} ${D}/boot/${UBOOT_ENV_BINARY}
    fi

    if [ "${UBOOT_EXTLINUX}" = "1" ]
    then
        install -Dm 0644 ${UBOOT_EXTLINUX_CONFIG} ${D}/${UBOOT_EXTLINUX_INSTALL_DIR}/${UBOOT_EXTLINUX_CONF_NAME}
    fi

}

do_deploy () {
    if [ -n "${UBOOT_CONFIG}" ]
    then
        for config in ${UBOOT_MACHINE}; do
            i=$(expr $i + 1);
            for type in ${UBOOT_CONFIG}; do
                j=$(expr $j + 1);
                if [ $j -eq $i ]
                then
                    install -d ${DEPLOYDIR}
                    install -m 644 ${B}/${config}/u-boot-${type}.${UBOOT_SUFFIX} ${DEPLOYDIR}/u-boot-${type}-${PV}-${PR}.${UBOOT_SUFFIX}
                    cd ${DEPLOYDIR}
                    ln -sf u-boot-${type}-${PV}-${PR}.${UBOOT_SUFFIX} ${UBOOT_SYMLINK}-${type}
                    ln -sf u-boot-${type}-${PV}-${PR}.${UBOOT_SUFFIX} ${UBOOT_SYMLINK}
                    ln -sf u-boot-${type}-${PV}-${PR}.${UBOOT_SUFFIX} ${UBOOT_BINARY}-${type}
                    ln -sf u-boot-${type}-${PV}-${PR}.${UBOOT_SUFFIX} ${UBOOT_BINARY}

                    # Deploy the uboot-initial-env
                    if [ -n "${UBOOT_INITIAL_ENV}" ]; then
                        install -D -m 644 ${B}/${config}/u-boot-initial-env-${type} ${DEPLOYDIR}/${UBOOT_INITIAL_ENV}-${MACHINE}-${type}-${PV}-${PR}
                        cd ${DEPLOYDIR}
                        ln -sf ${UBOOT_INITIAL_ENV}-${MACHINE}-${type}-${PV}-${PR} ${UBOOT_INITIAL_ENV}-${MACHINE}-${type}
                        ln -sf ${UBOOT_INITIAL_ENV}-${MACHINE}-${type}-${PV}-${PR} ${UBOOT_INITIAL_ENV}-${type}
                    fi
                fi
            done
            unset  j
        done
        unset  i
    else
        install -d ${DEPLOYDIR}
        install -m 644 ${B}/${UBOOT_BINARY} ${DEPLOYDIR}/${UBOOT_IMAGE}
        cd ${DEPLOYDIR}
        rm -f ${UBOOT_BINARY} ${UBOOT_SYMLINK}
        ln -sf ${UBOOT_IMAGE} ${UBOOT_SYMLINK}
        ln -sf ${UBOOT_IMAGE} ${UBOOT_BINARY}

        # Deploy the uboot-initial-env
        if [ -n "${UBOOT_INITIAL_ENV}" ]; then
            install -D -m 644 ${B}/u-boot-initial-env ${DEPLOYDIR}/${UBOOT_INITIAL_ENV}-${MACHINE}-${PV}-${PR}
            cd ${DEPLOYDIR}
            ln -sf ${UBOOT_INITIAL_ENV}-${MACHINE}-${PV}-${PR} ${UBOOT_INITIAL_ENV}-${MACHINE}
            ln -sf ${UBOOT_INITIAL_ENV}-${MACHINE}-${PV}-${PR} ${UBOOT_INITIAL_ENV}
        fi
    fi

    if [ -e ${WORKDIR}/fw_env.config ] ; then
        install -D -m 644 ${WORKDIR}/fw_env.config ${DEPLOYDIR}/fw_env.config-${MACHINE}-${PV}-${PR}
        cd ${DEPLOYDIR}
        ln -sf fw_env.config-${MACHINE}-${PV}-${PR} fw_env.config-${MACHINE}
        ln -sf fw_env.config-${MACHINE}-${PV}-${PR} fw_env.config
    fi

    if [ -n "${UBOOT_ELF}" ]
    then
        if [ -n "${UBOOT_CONFIG}" ]
        then
            for config in ${UBOOT_MACHINE}; do
                i=$(expr $i + 1);
                for type in ${UBOOT_CONFIG}; do
                    j=$(expr $j + 1);
                    if [ $j -eq $i ]
                    then
                        install -m 644 ${B}/${config}/${UBOOT_ELF} ${DEPLOYDIR}/u-boot-${type}-${PV}-${PR}.${UBOOT_ELF_SUFFIX}
                        ln -sf u-boot-${type}-${PV}-${PR}.${UBOOT_ELF_SUFFIX} ${DEPLOYDIR}/${UBOOT_ELF_BINARY}-${type}
                        ln -sf u-boot-${type}-${PV}-${PR}.${UBOOT_ELF_SUFFIX} ${DEPLOYDIR}/${UBOOT_ELF_BINARY}
                        ln -sf u-boot-${type}-${PV}-${PR}.${UBOOT_ELF_SUFFIX} ${DEPLOYDIR}/${UBOOT_ELF_SYMLINK}-${type}
                        ln -sf u-boot-${type}-${PV}-${PR}.${UBOOT_ELF_SUFFIX} ${DEPLOYDIR}/${UBOOT_ELF_SYMLINK}
                    fi
                done
                unset j
            done
            unset i
        else
            install -m 644 ${B}/${UBOOT_ELF} ${DEPLOYDIR}/${UBOOT_ELF_IMAGE}
            ln -sf ${UBOOT_ELF_IMAGE} ${DEPLOYDIR}/${UBOOT_ELF_BINARY}
            ln -sf ${UBOOT_ELF_IMAGE} ${DEPLOYDIR}/${UBOOT_ELF_SYMLINK}
        fi
    fi


     if [ -n "${SPL_BINARY}" ]
     then
        if [ -n "${UBOOT_CONFIG}" ]
        then
            for config in ${UBOOT_MACHINE}; do
                i=$(expr $i + 1);
                for type in ${UBOOT_CONFIG}; do
                    j=$(expr $j + 1);
                    if [ $j -eq $i ]
                    then
                        install -m 644 ${B}/${config}/${SPL_BINARY} ${DEPLOYDIR}/${SPL_IMAGE}-${type}-${PV}-${PR}
                        rm -f ${DEPLOYDIR}/${SPL_BINARYNAME} ${DEPLOYDIR}/${SPL_SYMLINK}-${type}
                        ln -sf ${SPL_IMAGE}-${type}-${PV}-${PR} ${DEPLOYDIR}/${SPL_BINARYNAME}-${type}
                        ln -sf ${SPL_IMAGE}-${type}-${PV}-${PR} ${DEPLOYDIR}/${SPL_BINARYNAME}
                        ln -sf ${SPL_IMAGE}-${type}-${PV}-${PR} ${DEPLOYDIR}/${SPL_SYMLINK}-${type}
                        ln -sf ${SPL_IMAGE}-${type}-${PV}-${PR} ${DEPLOYDIR}/${SPL_SYMLINK}
                    fi
                done
                unset  j
            done
            unset  i
        else
            install -m 644 ${B}/${SPL_BINARY} ${DEPLOYDIR}/${SPL_IMAGE}
            rm -f ${DEPLOYDIR}/${SPL_BINARYNAME} ${DEPLOYDIR}/${SPL_SYMLINK}
            ln -sf ${SPL_IMAGE} ${DEPLOYDIR}/${SPL_BINARYNAME}
            ln -sf ${SPL_IMAGE} ${DEPLOYDIR}/${SPL_SYMLINK}
        fi
    fi


    if [ -n "${UBOOT_ENV}" ]
    then
        install -m 644 ${B}/${UBOOT_ENV_BINARY} ${DEPLOYDIR}/${UBOOT_ENV_IMAGE}
        rm -f ${DEPLOYDIR}/${UBOOT_ENV_BINARY} ${DEPLOYDIR}/${UBOOT_ENV_SYMLINK}
        ln -sf ${UBOOT_ENV_IMAGE} ${DEPLOYDIR}/${UBOOT_ENV_BINARY}
        ln -sf ${UBOOT_ENV_IMAGE} ${DEPLOYDIR}/${UBOOT_ENV_SYMLINK}
    fi

    if [ "${UBOOT_EXTLINUX}" = "1" ]
    then
        install -m 644 ${UBOOT_EXTLINUX_CONFIG} ${DEPLOYDIR}/${UBOOT_EXTLINUX_SYMLINK}
        ln -sf ${UBOOT_EXTLINUX_SYMLINK} ${DEPLOYDIR}/${UBOOT_EXTLINUX_CONF_NAME}-${MACHINE}
        ln -sf ${UBOOT_EXTLINUX_SYMLINK} ${DEPLOYDIR}/${UBOOT_EXTLINUX_CONF_NAME}
    fi
}

