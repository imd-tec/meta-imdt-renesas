IMAGE_INSTALL:append = " \
	rz-tvm-runtime \
	kernel-module-mmngr \
	python3-modules \
	python3-pip \
	python3-wheel \
	python3-setuptools \
	python3-numpy \
	python3-pandas \
	python3-pillow \
	python3-opencv \
"

TOOLCHAIN_TARGET_TASK:append = " drpai "
