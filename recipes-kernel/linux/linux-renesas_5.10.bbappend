SRC_URI = "git://git@github.com/imd-tec/renesas-rz-linux-cip.git;protocol=ssh;branch=rzv2-5.10.y"
SRCREV = "83f2ae274562fe31c325565af264bb46e89fe54d"

COMPATIBLE_MACHINE_rzv2h_append = "|(imdt-v2h-sbc)"
COMPATIBLE_MACHINE_rzv2n_append = "|(imdt-v2n-sbc)"
