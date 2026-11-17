FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# The V2N DRP1 node is in our kernel tree; this EVK version clashes with it
SRC_URI:remove:imdt-v2n-sbc = "file://0001-arm64-dts-renesas-r9a09g056-Add-node-and-memory-area.patch"

# Renesas's DRP driver picks the SoC at build time; our kernel serves both
SRC_URI:append = " file://0001-drp-choose-V2N-or-V2H-at-probe-time.patch"
