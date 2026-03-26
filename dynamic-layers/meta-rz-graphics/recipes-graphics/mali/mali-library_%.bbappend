FILES:${PN}:append = " /etc/OpenCL/vendors/mali.icd"

# Mali headers go to a separate location
FILES:mali-opencl-dev = "${includedir}/mali-opencl ${libdir}/pkgconfig/mali-opencl.pc"

# Empty the loader package, keep dev with relocated headers
FILES:mali-opencl = ""
ALLOW_EMPTY:mali-opencl = "1"

RDEPENDS:${PN}:remove = "mali-opencl"

do_install:append() {
    # Install the mali ICD file
    install -d ${D}/etc/OpenCL/vendors
    echo "/usr/lib64/libmali.so" > ${D}/etc/OpenCL/vendors/mali.icd
    # Remove OpenCL loader - ocl-icd provides this
    rm -f ${D}${libdir}/libOpenCL.so*
    
    # Relocate Mali CL headers to avoid conflict with opencl-headers
    install -d ${D}${includedir}/mali-opencl
    mv ${D}${includedir}/CL/* ${D}${includedir}/mali-opencl/
    mv ${D}${libdir}/pkgconfig/OpenCL.pc ${D}${libdir}/pkgconfig/mali-opencl.pc
    rm -rf ${D}${includedir}/CL
}