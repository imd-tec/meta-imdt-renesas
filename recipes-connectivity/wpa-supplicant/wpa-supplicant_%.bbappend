#
# Copyright (c) 2022 IMD Technologies
#

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
   file://wpa_supplicant-nl80211-wlan0.conf \
"

SYSTEMD_AUTO_ENABLE = "disable"
SYSTEMD_SERVICE_${PN}_append = " wpa_supplicant-nl80211@wlan0.service "

do_install_append() {
   install -d ${D}${sysconfdir}/wpa_supplicant/
   install -D -m 600 ${WORKDIR}/wpa_supplicant-nl80211-wlan0.conf ${D}${sysconfdir}/wpa_supplicant/
}
