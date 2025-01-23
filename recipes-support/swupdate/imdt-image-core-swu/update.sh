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
		dd if=/tmp/bl2_bp_spi-imdt-v2h-sbc.bin of=boot.img  conv=notrunc 
		dd if=/tmp/fip-imdt-v2h-sbc.bin  of=boot.img conv=notrunc bs=512 seek=768 
		flashcp -v boot.img /dev/mtd0 
	fi

	# if current_root is emmc, flash the emmc with new bootloaders
	if [ "/dev/mmcblk0p2" == $CURRENT_ROOT ] || [ "/dev/mmcblk0p3" == $CURRENT_ROOT ]; then
		echo EMMC
		mmc bootpart enable 1 0 /dev/mmcblk0  # enable the first boot-area 0 for boot, no ack
		mmc bootbus set single_backward x1 x8 /dev/mmcblk0  # setup the boot bus config
		echo 0 > /sys/block/mmcblk0boot0/force_ro
		dd if=/tmp/bl2_bp_emmc-imdt-v2h-sbc.bin of=/dev/mmcblk0boot0 bs=512 skip=0 seek=1 >/dev/null 2>/dev/null
		dd if=/tmp/fip-imdt-v2h-sbc.bin of=/dev/mmcblk0boot0 bs=512 skip=0 seek=768 >/dev/null 2>/dev/null
	fi
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
			# reset the env variable back to zero
			echo "clearing bootloader overwrite flag..."
			fw_setenv "overwrite_bl" "0"
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
fi
