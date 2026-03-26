SUMMARY = "Murata Binaries"
LICENSE = "GPL-2.0-only"

LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=ffa10f40b98be2c2bc9608f56827ed23"

SRC_URI = " \
	git://github.com/murata-wireless/nxp-linux-calibration;protocol=http;branch=imx-6-1-1;name=nxp-linux-calibration \
	file://add_wlan.patch \
	file://switch_regions.sh \
	file://mlanconf.service \
"

SRCREV_nxp-linux-calibration = "6103e224be638f5b421c323993f29bb6c0ada44a"

S = "${WORKDIR}/git"

do_compile[noexec] = "1"

inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "mlanconf.service"

do_install () {
	install -d ${D}${sbindir}
	install -m 755 ${WORKDIR}/switch_regions.sh ${D}${sbindir}/switch_regions.sh

	# Install calibration source files (kept for switch_regions.sh modify_conf)
	install -d ${D}${nonarch_base_libdir}/firmware/nxp/murata/files/1XK
	install -m 444 ${S}/murata/files/1XK/* ${D}${nonarch_base_libdir}/firmware/nxp/murata/files/1XK
	install -m 0644 ${S}/murata/files/wifi_mod_para_murata.conf ${D}${nonarch_base_libdir}/firmware/nxp/murata/files/wifi_mod_para_murata.conf
	install -m 444 ${S}/murata/README.txt ${D}${nonarch_base_libdir}/firmware/nxp/murata/README.txt

	# Install 1XK calibration files directly to firmware root
	install -m 0644 ${S}/murata/files/1XK/txpower_*.bin ${D}${nonarch_base_libdir}/firmware/nxp/
	install -m 0644 ${S}/murata/files/1XK/ed_mac.bin ${D}${nonarch_base_libdir}/firmware/nxp/
	install -m 0644 ${S}/murata/files/bt_power_config_1.sh ${D}${nonarch_base_libdir}/firmware/nxp/
	# cntry_txpwr=1 loads txpower_<ISO>.bin by exact name — no fallback.
	# EU uses ISO code DE (Germany/ETSI); symlink so iw reg set DE finds it.
	ln -sf txpower_EU.bin ${D}${nonarch_base_libdir}/firmware/nxp/txpower_DE.bin

	# Set murata wifi_mod_para.conf as default
	install -m 0644 ${S}/murata/files/wifi_mod_para_murata.conf ${D}${nonarch_base_libdir}/firmware/nxp/wifi_mod_para.conf

	# Install mlanconf systemd service
	install -d ${D}${systemd_unitdir}/system
	install -m 0644 ${WORKDIR}/mlanconf.service ${D}${systemd_unitdir}/system
}

FILES:${PN} += " \
    ${nonarch_base_libdir}/firmware/nxp \
    ${sbindir} \
"

RDEPENDS:${PN} = " \
    iw \
    sed \
    wireless-regdb-static \
"
