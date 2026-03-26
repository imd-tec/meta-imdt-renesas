#: Title       : wifi-lib.sh
#: Author      : Lewis Purvis <lewisp@imd-tec.com>
#: Description : Library of functions for use by the WiFi control scripts

NETWORKD_DIR=/lib/systemd/network

function enable_access_point
{
    mv ${NETWORKD_DIR}/25-wlan.network ${NETWORKD_DIR}/25-wlan.network.disabled 2>/dev/null
    mv ${NETWORKD_DIR}/21-ap.network.disabled ${NETWORKD_DIR}/21-ap.network 2>/dev/null
    networkctl reload
    systemctl enable hostapd.service
    systemctl start hostapd.service
}

function disable_access_point
{
    systemctl stop hostapd.service
    systemctl disable hostapd.service
    mv ${NETWORKD_DIR}/21-ap.network ${NETWORKD_DIR}/21-ap.network.disabled 2>/dev/null
    networkctl reload
}

function restart_access_point
{
    systemctl restart hostapd.service
}

function enable_station
{
    mv ${NETWORKD_DIR}/21-ap.network ${NETWORKD_DIR}/21-ap.network.disabled 2>/dev/null
    mv ${NETWORKD_DIR}/25-wlan.network.disabled ${NETWORKD_DIR}/25-wlan.network 2>/dev/null
    networkctl reload
    systemctl enable wpa_supplicant-nl80211@wlan0.service
    systemctl start wpa_supplicant-nl80211@wlan0.service
}

function disable_station
{
    systemctl stop wpa_supplicant-nl80211@wlan0.service
    systemctl disable wpa_supplicant-nl80211@wlan0.service
    mv ${NETWORKD_DIR}/25-wlan.network ${NETWORKD_DIR}/25-wlan.network.disabled 2>/dev/null
    networkctl reload
}

function restart_station
{
    systemctl restart wpa_supplicant-nl80211@wlan0.service
}

function take_down_wlan0
{
    ip link set wlan0 down
}
