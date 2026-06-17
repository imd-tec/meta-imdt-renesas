# Copyright (c) 2025 IMD Technologies

DESCRIPTION = "Create a base SWUpdate image for the IMDT-V2H-SBC and IMDT-V2N-SBC"

require include/imdt-image-swu.inc

inherit swupdate 

# Dependencies to build before creating the SWUpdate image
IMDT_BASE_IMAGE = "imdt-image-base"