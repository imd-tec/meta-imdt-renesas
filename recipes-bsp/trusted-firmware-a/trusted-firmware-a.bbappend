SRC_URI_imdt-v2h-sbc = "git://git@github.com/imd-tec/rzg-trusted-firmware-a.git;protocol=ssh;branch=imdt-v2.7.0"
SRCREV_imdt-v2h-sbc = "e9855f0543a36926b6c8b7bcee3ae3aa5b4f2ffc"

COMPATIBLE_MACHINE_rzv2h_append = "|imdt-v2h-sbc"
COMPATIBLE_MACHINE_rzv2n_append = "|imdt-v2n-sbc"

# Checked the rzg_trusted-firmware-a.tar.bz2 archive
# The BOARD variable is used to define the path to a directory containing a *.mk file
# This Makefile specifies the source files for the LPDDR4 memory driver and some configuration variables
# For now, it's safe to use the files for the evk_alpha
EXTRA_FLAGS_imdt-v2h-sbc = "BOARD=evk_alpha ENABLE_STACK_PROTECTOR=default"
EXTRA_FLAGS_imdt-v2n-sbc = "BOARD=evk_1 ENABLE_STACK_PROTECTOR=default"