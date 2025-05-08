SRC_URI = "git://git@github.com/imd-tec/renesas-rz-linux-cip.git;protocol=ssh;branch=rzv2-5.10.y"
SRCREV = "e80d4c410c259e5207fad5aed93dbd882d1c3126"

COMPATIBLE_MACHINE_rzv2h_append = "|(imdt-v2h-sbc)"
COMPATIBLE_MACHINE_rzv2n_append = "|(imdt-v2n-sbc)"
