#!/bin/bash

CURRENT_ROOT=/dev/mmcblk0boot0
ENV_OFFSET=0x20000
ENV_SIZE=0x20000
# Update the fw_env.config file
echo "${CURRENT_ROOT} ${ENV_OFFSET} ${ENV_SIZE}" > /etc/fw_env.config
