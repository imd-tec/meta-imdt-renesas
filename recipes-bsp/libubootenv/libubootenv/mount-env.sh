#!/bin/sh
set -x
# Ensure /env directory exists
if [ ! -d /env ]; then
    mkdir /env
fi

# Determine the root device (i.e., where the system is booted from)
ROOT_DEVICE=$(mount | grep "on / " | awk '{print $1}')

# Extract the base device name (mmcblk0 or mmcblk1) from the root device
DEVICE_NAME=$(echo $ROOT_DEVICE | sed "s|/dev/mmcblk||g" | sed "s|p[0-9]*$||g")

# Dynamically construct the environment partition path (e.g., /dev/mmcblk1p1 or /dev/mmcblk0p1)
ENV_PARTITION="/dev/mmcblk${DEVICE_NAME}p1"

# Check if the partition is already mounted
if mount | grep -q "$ENV_PARTITION"; then
    # If it's already mounted, create a bind mount to /env
    BIND_SOURCE=$(findmnt -n -o TARGET -S "$ENV_PARTITION")
    if [ -n "$BIND_SOURCE" ]; then
        mount --bind "$BIND_SOURCE" /env
        echo "$ENV_PARTITION is already mounted, bind mounting to /env."
    else
        echo "Could not find the source mount point for $ENV_PARTITION."
        exit 1
    fi
else
    # If it's not mounted, mount it to /env
    if [ -b "$ENV_PARTITION" ]; then
        mount "$ENV_PARTITION" /env
        echo "$ENV_PARTITION mounted to /env."
    else
        echo "No env partition found for $ENV_PARTITION."
        exit 1
    fi
fi


