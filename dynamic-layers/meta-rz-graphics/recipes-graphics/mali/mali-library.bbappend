FILES_${PN}_append = "/etc/OpenCL/vendors/mali.icd"

do_install_append() {
    # Install the mali ICD file that is used by OpenCL
    install -d ${D}/etc/OpenCL/vendors
    echo "/usr/lib64/libmali.so" > ${D}/etc/OpenCL/vendors/mali.icd
}
