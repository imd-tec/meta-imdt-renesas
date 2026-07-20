FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# Replace android-gadget-start with an improved version that:
# - replaces the fixed sleep 10 with a UDC availability polling loop
# - waits for FunctionFS ep1 before binding to avoid adbd descriptor race
# - retries the UDC bind until it succeeds
SRC_URI:remove = "file://android-gadget-start"
SRC_URI:append = " file://android-gadget-start"
