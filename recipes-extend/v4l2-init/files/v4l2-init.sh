#!/bin/bash
#===============================================================================
#title           : v4l2-init.sh
#description     : This script initialises a media device pipeline
#     
#usage           : bash v4l2-init.sh --device 0 --width 1920 --height 1080
#===============================================================================
set -e

# At the moment, we only support setting up pipelines for /dev/media0 and /dev/media1
MAX_DEVICE_ID=1

# Default values when the user provides no arguments or a partially populated argument list
DEFAULT_DEVICE_ID=0
DEFAULT_CAPTURE_WIDTH="1920"
DEFAULT_CAPTURE_HEIGHT="1080"

SUPPORTED_CAPTURE_RESOLUTIONS=("1280x720" "1920x1080" "4096x3072")

# Elements used to construct pipelines associated with each media device
SENSOR_NAMES=("ap1302.0-003c" "ap1302.1-003d")
MIPI_CSI_ELEMENT_NAMES=("rzg2l_csi2 16000400.csi20" "rzg2l_csi2 16010400.csi21")
CRU_ELEMENT_NAMES=("CRU output" "CRU output")


function check_sensor_resolution() {
    local target_resolution="${1}x${2}"
    local matching_resolution=""

    for supported_resolution in ${SUPPORTED_CAPTURE_RESOLUTIONS[@]}; do
        if [[ "${target_resolution}" == "${supported_resolution}" ]]; then
            matching_resolution="${supported_resolution}"
        fi 
    done

    if [[ -z "${matching_resolution}" ]]; then
        echo "ERROR: Selected resolution is not supported"
        echo "Use the --help option to see what resolutions are available"
        exit 1
    fi
}

function check_sensor_exists() {
    local media_device=$1
    local sensor_name=$2
    local sensor_dev_name=""
    
    # If the sensor exists it will return the /dev file
    # If it doesn't exist, it returns "Entity '${sensor_name}' not found"
    sensor_dev_name="$(media-ctl -d "${media_device}" -e "${sensor_name}")"

    if [[ "${sensor_dev_name}" == "Entity '${sensor_name}' not found" ]]; then
        echo "ERROR: Sensor (${sensor_name}) not found. Please make sure the sensor is connected to the board"
        exit 1
    fi    
}

function create_pipeline() {
    local media_device_id=$1
    local capture_width=$2
    local capture_height=$3

    local media_device="/dev/media${media_device_id}"

    if [[ "${media_device_id}" -gt "${MAX_DEVICE_ID}" ]]; then
        echo "ERROR: A device ID bigger than ${MAX_DEVICE_ID} is not supported in this release"
        exit 1
    fi
    if [[ "${media_device_id}" -lt "0" ]]; then
        echo "ERROR: Invaid device ID"
        exit 1
    fi
    
    sensor_element=${SENSOR_NAMES["${media_device_id}"]}
    mipi_csi_element=${MIPI_CSI_ELEMENT_NAMES["${media_device_id}"]}
    cru_element=${CRU_ELEMENT_NAMES["${media_device_id}"]}

    check_sensor_exists "${media_device}" "${sensor_element}"
    check_sensor_resolution "${capture_width}" "${capture_height}"

    # Clear the media pipeline associated with a media device
    media-ctl -d "${media_device}" -r

    # Create links between device pads
    media-ctl -d "${media_device}" -l "'${sensor_element}':0 -> '${mipi_csi_element}':0 [1]"
    media-ctl -d "${media_device}" -l "'${mipi_csi_element}':1 -> '${cru_element}':0 [1]"

    # Configure pad resolution and image format
    media-ctl -d "${media_device}" -V "'${sensor_element}':0 [fmt:YUYV8_1X16/${capture_width}x${capture_height} field:none colorspace:srgb]"
    media-ctl -d "${media_device}" -V "'${mipi_csi_element}':0 [fmt:YUYV8_1X16/${capture_width}x${capture_height}  field:none colorspace:srgb]"

    echo "Succesfully linked ${sensor_element} to ${mipi_csi_element} with format YUYV8_1X16 and resolution ${capture_width}x${capture_height}"
}

function print_usage() {
cat << EOF
Usage: v4l2-init [options]

Options:
  --help                    show this help message and exit
  --device DEVICE_ID        The id of the media device, where 0 corresponds to /dev/media0
  --width WIDTH             Width of capture image
  --height HEIGHT           Height of capture image 

If no options are provided this script will configure /dev/media${DEFAULT_DEVICE_ID} to produce
capture images that are ${DEFAULT_CAPTURE_WIDTH}x${DEFAULT_CAPTURE_HEIGHT}

Available Capture Resolutions (width x height):
  ${SUPPORTED_CAPTURE_RESOLUTIONS[0]}
  ${SUPPORTED_CAPTURE_RESOLUTIONS[1]}
  ${SUPPORTED_CAPTURE_RESOLUTIONS[2]}
EOF
}

function parse_shell_args() {
    local device_id=${DEFAULT_DEVICE_ID}
    local capture_width=${DEFAULT_CAPTURE_WIDTH}
    local capture_height=${DEFAULT_CAPTURE_HEIGHT}

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --device)  device_id="$2";                  shift 2;;
            --width)   capture_width="$2";              shift 2;;
            --height)  capture_height="$2";             shift 2;;
            --help)    print_usage;                     exit 0;;
            *)         echo "ERROR: Unknown parameter passed: $1";
                       print_usage; 
                       exit 1;;
        esac
    done

    create_pipeline "${device_id}" "${capture_width}" "${capture_height}"
}

parse_shell_args "$@"
