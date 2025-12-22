SRC_URI = "git://git@github.com/imd-tec/renesas-rz-linux-cip.git;protocol=ssh;branch=rzv2-5.10.y"
SRCREV = "155a9f014ff875dd3efb8a075144a27ff0c95621"

COMPATIBLE_MACHINE_rzv2h_append = "|(imdt-v2h-sbc)"
COMPATIBLE_MACHINE_rzv2n_append = "|(imdt-v2n-sbc)"
