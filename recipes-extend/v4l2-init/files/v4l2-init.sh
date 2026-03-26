#!/bin/bash
#===============================================================================
# title       : v4l2-init.sh
# description : Initialises a media device pipeline for CRU capture
# usage       : v4l2-init.sh --device 0 --width 1920 --height 1080
#===============================================================================
set -e

DEFAULT_DEVICE_ID=0
DEFAULT_CAPTURE_WIDTH=1920
DEFAULT_CAPTURE_HEIGHT=1080

SUPPORTED_CAPTURE_RESOLUTIONS=("1280x720" "1920x1080" "4096x3072")

check_resolution() {
    local target="${1}x${2}"

    for res in "${SUPPORTED_CAPTURE_RESOLUTIONS[@]}"; do
        [[ "$target" == "$res" ]] && return 0
    done

    echo "ERROR: Resolution ${target} is not supported"
    echo "Supported: ${SUPPORTED_CAPTURE_RESOLUTIONS[*]}"
    exit 1
}

# Find a media entity by matching a pattern in its name.
# Usage: find_entity /dev/mediaX "pattern"
# Returns the full entity name or exits on failure.
find_entity() {
    local media_device=$1
    local pattern=$2
    local entity

    entity=$(media-ctl -d "$media_device" -p | grep "^- entity" | grep "$pattern" | head -1 | sed 's/^- entity [0-9]*: \(.*\) ([0-9]* pad.*/\1/')

    if [[ -z "$entity" ]]; then
        echo "ERROR: No entity matching '${pattern}' found on ${media_device}" >&2
        exit 1
    fi

    echo "$entity"
}

# Discover the pipeline entities from the media device topology.
# The CRU pipeline is: sensor (ap1302) -> CSI -> cru-ip -> CRU output
discover_pipeline() {
    local media_device=$1

    if [[ ! -e "$media_device" ]]; then
        echo "ERROR: ${media_device} does not exist"
        exit 1
    fi

    SENSOR=$(find_entity "$media_device" "ap1302")
    CSI=$(find_entity "$media_device" "csi-")
    CRU_IP=$(find_entity "$media_device" "cru-ip")
    VIDEO_DEVICE=$(media-ctl -d "$media_device" -e 'CRU output')
}

create_pipeline() {
    local media_device_id=$1
    local width=$2
    local height=$3
    local media_device="/dev/media${media_device_id}"

    check_resolution "$width" "$height"
    discover_pipeline "$media_device"

    local fmt="YUYV8_1X16/${width}x${height} field:none colorspace:srgb"

    # Configure media bus format on each pad in the pipeline
    media-ctl -d "$media_device" -V "'${SENSOR}':0 [fmt:${fmt}]"
    media-ctl -d "$media_device" -V "'${CSI}':0 [fmt:${fmt}]"
    media-ctl -d "$media_device" -V "'${CRU_IP}':0 [fmt:${fmt}]"

    # Set the V4L2 capture format on the video device
    v4l2-ctl -d "$VIDEO_DEVICE" --set-fmt-video=width=${width},height=${height},pixelformat=YUYV

    echo "Configured ${SENSOR} -> ${CSI} -> ${CRU_IP} -> ${VIDEO_DEVICE}"
    echo "  Format: YUYV8_1X16 ${width}x${height}"
}

print_usage() {
    cat << EOF
Usage: v4l2-init [options]

Options:
  --help                    Show this help message and exit
  --device DEVICE_ID        Media device index (0 = /dev/media0, 1 = /dev/media1)
  --width WIDTH             Capture width
  --height HEIGHT           Capture height

Defaults: /dev/media${DEFAULT_DEVICE_ID} at ${DEFAULT_CAPTURE_WIDTH}x${DEFAULT_CAPTURE_HEIGHT}

Supported resolutions:
  ${SUPPORTED_CAPTURE_RESOLUTIONS[*]}
EOF
}

main() {
    local device_id=$DEFAULT_DEVICE_ID
    local width=$DEFAULT_CAPTURE_WIDTH
    local height=$DEFAULT_CAPTURE_HEIGHT

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --device) device_id="$2"; shift 2 ;;
            --width)  width="$2";     shift 2 ;;
            --height) height="$2";    shift 2 ;;
            --help)   print_usage;    exit 0  ;;
            *)        echo "ERROR: Unknown option: $1"
                      print_usage
                      exit 1 ;;
        esac
    done

    create_pipeline "$device_id" "$width" "$height"
}

main "$@"
