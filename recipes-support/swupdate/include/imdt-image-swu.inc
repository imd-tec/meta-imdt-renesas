LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Proprietary;md5=0557f9d92cf58f2ccdd50f62f8ac0b28"

FILESEXTRAPATHS:prepend := "${THISDIR}/../files:"

IMAGE_DEPENDS = "${IMDT_BASE_IMAGE}"

SRC_URI = " \
    file://update.sh \
    file://sw-description.in \
"

IMDT_IMAGE_NAME = "${IMDT_BASE_IMAGE}-${MACHINE}.rootfs"
IMDT_ROOTFS_SUFFIX = "tar.gz"

SWUPDATE_IMAGES = " \
    bl2_bp_spi-${MACHINE}.bin \
    bl2_bp_mmc-${MACHINE}.bin \
    fip-${MACHINE}.bin \
    ${IMDT_IMAGE_NAME}.${IMDT_ROOTFS_SUFFIX} \
"

python do_generate_sw_description() {
    import os

    workdir = d.getVar('WORKDIR', True)

    sw_desc_in_path = os.path.join(workdir, "sw-description.in")
    if not os.path.exists(sw_desc_in_path):
        bb.fatal("sw-description.in not found in WORKDIR")

    sw_desc_output_path = os.path.join(workdir, "sw-description")

    with open(sw_desc_in_path, 'r') as infile:
        content = infile.read()

    # Replace fixed placeholders
    content = content.replace('@TARFILE@', d.getVar('IMDT_IMAGE_NAME') + "." + d.getVar('IMDT_ROOTFS_SUFFIX'))
    content = content.replace('@MACHINE@', d.getVar('MACHINE'))

    # Dynamically create 'files' entries
    swupdate_images = d.getVar('SWUPDATE_IMAGES').split()
    file_entries = []
    for fname in swupdate_images:
        if fname.endswith('.bin'):
            entry = f'''\
            {{
                filename = "{fname}";
                path = "{fname}";
            }}'''
            file_entries.append(entry)

    files_block = "files:\n        (\n" + ",\n".join(file_entries) + "\n        );"
    content = content.replace('@FILES_BLOCK@', files_block)

    # Replace the @COMPRESSION_TYPE@ placeholder
    rootfs_suffix = d.getVar('IMDT_ROOTFS_SUFFIX')
    if rootfs_suffix == "tar.zst":
        compression_type = 'zstd'
    else:
        compression_type = 'zlib'
    content = content.replace('@COMPRESSION_TYPE@', compression_type)

    with open(sw_desc_output_path, 'w') as outfile:
        outfile.write(content)

    bb.note("Generated sw-description at: %s" % sw_desc_output_path)
}

addtask do_generate_sw_description after do_unpack before do_swuimage