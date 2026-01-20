REPO_DIR = "${TOPDIR}/../.repo"

do_install[file-checksums] += "${REPO_DIR}/manifest.xml:True \
                               ${REPO_DIR}/manifests/*:True"

do_install_append() {
    # Navigate to the repo manifest directory
    MANIFEST_DIR="${TOPDIR}/../.repo/manifests"
    BSP_VERSION="0.0.0"
    MANIFEST_NAME="Unknown"

    # Check if the manifest directory exists
    if [ -d "${MANIFEST_DIR}" ]; then
        # Extract the included manifest name from the root manifest file
        INCLUDED_MANIFEST=$(grep -oP '(?<=<include name=")[^"]+' ${TOPDIR}/../.repo/manifest.xml)
        
        # Define the full path to the included manifest file
        INCLUDED_MANIFEST_PATH="${MANIFEST_DIR}/${INCLUDED_MANIFEST}"
        
        # Check if the included manifest exists
        if [ -f "${INCLUDED_MANIFEST_PATH}" ]; then
            LINE=$(grep -oP '(?<=<manifest )[^\>]*' ${INCLUDED_MANIFEST_PATH})
            # Extract the name and version from the included manifest
            MANIFEST_NAME=$(echo $LINE | sed -n 's/.*name="\([^"]*\)".*/\1/p')
            BSP_VERSION=$(echo $LINE | sed -n 's/.*version="\([^"]*\)".*/\1/p')
            
            # If the version isn't found, set it to NO_TAG
            if [ -z "$BSP_VERSION" ]; then
                BSP_VERSION="NO_TAG"
            fi
        fi
    fi

    # Write the custom /etc/issue file with the manifest details
    echo "IMDT BSP v${BSP_VERSION} (Manifest: ${MANIFEST_NAME})" > ${D}${sysconfdir}/issue
}
