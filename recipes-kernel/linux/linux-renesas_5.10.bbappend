SRC_URI = "git://git@github.com/imd-tec/renesas-rz-linux-cip.git;protocol=ssh;branch=rzv2-5.10.y"
SRCREV = "ca6e978ea9ef1af1fabfc9979af2de4ce4fb402c"

COMPATIBLE_MACHINE_rzv2h_append = "|(imdt-v2h-sbc)"
COMPATIBLE_MACHINE_rzv2n_append = "|(imdt-v2n-sbc)"
