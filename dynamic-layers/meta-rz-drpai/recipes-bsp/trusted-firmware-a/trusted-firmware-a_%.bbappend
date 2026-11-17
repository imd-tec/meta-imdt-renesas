# meta-rz-drpai's V2N TF-A patch sets EVK DDR timings and AXI QoS for DRP-AI.
# It applies with fuzz to our TF-A, and DRP-AI runs correctly without it.
SRC_URI:remove:imdt-v2n-sbc = "file://0000-ddr_param_def_lpddr4-rzv2n_1.patch"
