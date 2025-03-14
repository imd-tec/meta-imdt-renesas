FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_imdt-v2n-sbc = "file://Flash_Writer_SCIF_RZV2N_EVK_LPDDR4X.mot"
SRC_URI_imdt-v2n-sbc[md5sum] = "678d5d69acb5ecea250bf51ac10ee308"
SRC_URI_imdt-v2n-sbc[sha256sum] = "bfb6f22fa65606aa999de1763a67fdfad065b2157a11ddddd0857b08eae811a9"

do_deploy_imdt-v2n-sbc() {
	install -d ${DEPLOYDIR}
	install -m 755 ${S}/Flash_Writer_SCIF_RZV2N_EVK_LPDDR4X.mot ${DEPLOYDIR}
}
COMPATIBLE_MACHINE_append = "|(imdt-v2)"