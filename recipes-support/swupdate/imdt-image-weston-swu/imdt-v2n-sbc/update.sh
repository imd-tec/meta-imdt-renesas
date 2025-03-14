#!/bin/sh

if [ $# -lt 1 ]; then
	exit 0;
fi

function get_current_root_device
{
	for i in `cat /proc/cmdline`; do
		if [ ${i:0:5} = "root=" ]; then
			CURRENT_ROOT="${i:5}"
		fi
	done
}

function get_update_part
{
	CURRENT_PART="${CURRENT_ROOT: -1}"
	if [ $CURRENT_PART = "2" ]; then
        	UPDATE_BOOT_PART="3";
	else
        	UPDATE_BOOT_PART="2";
	fi
}

function get_update_device
{
    UPDATE_BOOT_DEV=${CURRENT_ROOT%?}${UPDATE_BOOT_PART}
}

function write_bootloader
{
	# write boot img
	echo "This will overwrite the current bootloader! Changes CANNOT be reverted!"
	echo "${PWD}"

	# if current_root is sdcard, flash the QSPI with new bootloaders
	if [ "/dev/mmcblk1p2" == $CURRENT_ROOT ] || [ "/dev/mmcblk1p3" == $CURRENT_ROOT ]; then
		echo SD
		dd if=/dev/zero of=boot.img bs=1024 count=1024 
		dd if=/tmp/bl2_bp_spi-imdt-v2n-sbc.bin of=boot.img  conv=notrunc,fsync 
		dd if=/tmp/fip-imdt-v2n-sbc.bin  of=boot.img conv=notrunc,fsync bs=512 seek=768 
		flashcp -v boot.img /dev/mtd0 
	fi

	# if current_root is emmc, flash the emmc with new bootloaders
	if [ "/dev/mmcblk0p2" == $CURRENT_ROOT ] || [ "/dev/mmcblk0p3" == $CURRENT_ROOT ]; then
		echo EMMC
		mmc bootpart enable 1 0 /dev/mmcblk0  # enable the first boot-area 0 for boot, no ack
		mmc bootbus set single_backward x1 x8 /dev/mmcblk0  # setup the boot bus config
		echo 0 > /sys/block/mmcblk0boot0/force_ro
		dd if=/tmp/bl2_bp_mmc-imdt-v2n-sbc.bin of=/dev/mmcblk0boot0 bs=512 skip=0 seek=1 >/dev/null 2>/dev/null
		dd if=/tmp/fip-imdt-v2n-sbc.bin of=/dev/mmcblk0boot0 bs=512 skip=0 seek=768 >/dev/null 2>/dev/null
	fi
}

function update_bootcmd
{
	# Define the variable name we're looking for
	VAR_NAME="bootcmd"

	# Read the current U-Boot environment
	CURRENT_VALUE=$(fw_printenv $VAR_NAME 2>/dev/null | cut -d '=' -f2-)

	# Check if the variable was found
	if [ -z "$CURRENT_VALUE" ]; then
		echo "Error: Unable to read $VAR_NAME from U-Boot environment"
		return 1
	fi

	echo "Current $VAR_NAME: $CURRENT_VALUE"

	# Define the injection point and new string to inject
	PREPEND_STRING="run update_post; "

	# Remove any existing instances of PREPEND_STRING from CURRENT_VALUE
	CLEANED_VALUE="${CURRENT_VALUE//$PREPEND_STRING/}"

	# Prepend the cleaned value with PREPEND_STRING
	NEW_VALUE="${PREPEND_STRING}${CLEANED_VALUE}"
	echo "Setting $VAR_NAME to: $NEW_VALUE"

	# Write the new value back to the U-Boot environment
	fw_setenv $VAR_NAME "$NEW_VALUE"

	# Verify the change
	UPDATED_VALUE=$(fw_printenv $VAR_NAME 2>/dev/null | cut -d '=' -f2-)
	if [ "$UPDATED_VALUE" = "$NEW_VALUE" ]; then
		echo "Successfully updated $VAR_NAME to: $UPDATED_VALUE"
	else
		echo "Error: Failed to update $VAR_NAME"
		return 1
	fi

	# Get the partition we just updated
	get_update_part

	echo "Setting update_post to reset U-Boot environment"
	fw_setenv update_post "env default -a; setenv mmcpart ${UPDATE_BOOT_PART}; saveenv;"
}

if [ $1 == "preinst" ]; then

	#!/bin/bash
	echo "This script is: $0"
	echo "Called by: $(ps -o comm= $PPID)"
	if [[ "$0" == "$BASH_SOURCE" ]]; then
		echo "The script is executed directly."
	else
		echo "The script is being sourced."
	fi

	# get the current root device
	get_current_root_device

	# get the devices to be updated
	get_update_part
	get_update_device

	# create symlinks for the update process
    ln -sf $UPDATE_BOOT_DEV /dev/update

	# Get the output of fw_printenv
	env_output=$(fw_printenv)

	# Search for the line containing overwrite_bl
	overwrite_bl_line=$(echo "$env_output" | grep '^overwrite_bl=')

	# Check if the line exists
	if [ -n "$overwrite_bl_line" ]; then
		# Extract the value after '='
		overwrite_bl_value=$(echo "$overwrite_bl_line" | cut -d'=' -f2)

		# Check if the value is 1
		if [ "$overwrite_bl_value" -eq 1 ]; then
			echo "overwrite_bl is set to 1. Flashing bootloader..."
			write_bootloader

			# No need to reset overwrite_bl flag to 0, as it will be reset by the update_post
			# update the bootcmd
			update_bootcmd
		fi
	fi
fi

if [ $1 == "postinst" ]; then

	# get the current root device
	get_current_root_device

	# get the devices to be updated
	get_update_part
    get_update_device

	fw_setenv mmcpart $UPDATE_BOOT_PART

	sync
fi
