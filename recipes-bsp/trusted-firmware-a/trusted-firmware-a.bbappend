
COMPATIBLE_MACHINE_rzv2h = "(rzv2h-dev|rzv2h-evk-alpha|rzv2h-evk-ver1|imdt-rzv2h-evk)"

# Checked the rzg_trusted-firmware-a.tar.bz2 archive
# The BOARD variable is used to define the path to a directory containing a *.mk file
# This Makefile specifies the source files for the LPDDR4 memory driver and some configuration variables
# For now, it's safe to use the files for the evk_alpha
EXTRA_FLAGS_imdt-rzv2h-evk = "BOARD=evk_alpha ENABLE_STACK_PROTECTOR=default"
