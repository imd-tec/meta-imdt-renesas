# Use virtual provider instead of hardcoded opencl-icd-loader
DEPENDS_remove = "opencl-icd-loader"
DEPENDS += "virtual/libopencl"