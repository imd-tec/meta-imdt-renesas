#
# Copyright (c) 2024 IMD Technologies
#

DESCRIPTION = "Package group for all IMDT utilities"

LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    imdt-audio-utils \
    imdt-can-utils \
    imdt-ethernet-utils \
"
