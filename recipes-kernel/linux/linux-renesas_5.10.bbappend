SRC_URI = "git://git@github.com/imd-tec/renesas-rz-linux-cip.git;protocol=ssh;branch=rzv2-5.10.y"
SRCREV = "6a553d519e6f799c397ca8feeb177a1af843a718"

COMPATIBLE_MACHINE_rzv2h_append = "|(imdt-v2h-sbc)"
COMPATIBLE_MACHINE_rzv2n_append = "|(imdt-v2n-sbc)"
