#!/bin/bash
#: Title       : get-connection-status.sh
#: Author      : Paul Thomson <pault@imd-tec.com>
#: Description : Echoes the station connection status in JSON format

MODE=`/opt/imdt/wifi/get-wifi-mode.sh`

if [ "$MODE" != "STA" ]
then
    echo "WiFi interface is not in STAtion mode"
    exit 1
fi

STATUS_FILE=$(mktemp)

SSID=""
WPA_STATE=""
RSSI=""
FREQUENCY=""

if wpa_cli -i wlan0 status > "$STATUS_FILE"; then
    while IFS== read KEY VALUE; do
        case $KEY in
            "ssid") SSID=$VALUE;;
            "wpa_state") WPA_STATE=$VALUE;;
            *);;
        esac
    done < "$STATUS_FILE"
fi

rm "$STATUS_FILE"

if [ "$WPA_STATE" == "COMPLETED" ]; then
    SIGNAL_POLL_FILE=$(mktemp)

    if wpa_cli -i wlan0 signal_poll > "$SIGNAL_POLL_FILE"; then
        while IFS== read KEY VALUE; do
            case $KEY in
                "RSSI") RSSI=$VALUE;;
                "FREQUENCY") FREQUENCY=$VALUE;;
                *);;
            esac
        done < "$SIGNAL_POLL_FILE"
    fi

    rm "$SIGNAL_POLL_FILE"
fi

echo -ne "{"
echo -ne "\"wpa_state\":\"$WPA_STATE\","
echo -ne "\"ssid\":\"$SSID\","
echo -ne "\"rssi\":\"$RSSI\","
echo -ne "\"frequency\":\"$FREQUENCY\""
echo -ne "}"
echo ""