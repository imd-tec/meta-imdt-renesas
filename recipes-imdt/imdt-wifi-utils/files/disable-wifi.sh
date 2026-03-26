#!/bin/bash
#: Title       : disable-wifi.sh
#: Author      : Paul Thomson <pault@imd-tec.com>
#: Description : Disables the WiFi interfaces

. /opt/imdt/wifi/wifi-lib.sh

disable_access_point

disable_station

take_down_wlan0
