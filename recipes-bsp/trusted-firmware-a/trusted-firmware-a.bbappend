SRC_URI = "git://git@github.com/imd-tec/rzg-trusted-firmware-a-dev.git;protocol=ssh;branch=imdt-v2.7.0"
SRCREV = "8b0b10c265d105506be2a1fe9547fdf3f4451984"

COMPATIBLE_MACHINE_rzv2h = "(rzv2h-dev|rzv2h-evk-alpha|rzv2h-evk-ver1|imdt-v2h-sbc)"

# Checked the rzg_trusted-firmware-a.tar.bz2 archive
# The BOARD variable is used to define the path to a directory containing a *.mk file
# This Makefile specifies the source files for the LPDDR4 memory driver and some configuration variables
# For now, it's safe to use the files for the evk_alpha
EXTRA_FLAGS_imdt-v2h-sbc = "BOARD=evk_alpha ENABLE_STACK_PROTECTOR=default"
