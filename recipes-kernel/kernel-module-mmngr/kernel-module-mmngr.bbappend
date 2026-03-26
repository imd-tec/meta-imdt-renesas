# The mmngr.ko embeds TMPDIR paths via modpost (KERNELSRC) and DWARF (M=$(PWD)).
# This is inherent to out-of-tree Kbuild modules built against a staging kernel tree.
INSANE_SKIP:${PN} += "buildpaths"
