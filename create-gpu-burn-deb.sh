#!/bin/bash -xe

if [[ "$(id -u)" != 0 ]] ; then
    exec fakeroot "$0" "$@"
fi

cuda_ver="${1:-10.0}"
cuda_deb_ver=${cuda_ver//[.]/-}
nvcc_path="${2:-/usr/local/cuda-${cuda_ver}/bin/nvcc}"
cuda_arch="${3:-62}"

PROJ_NAME=pho-gpu-burn
PROJ_VER="0.0.1-cuda${cuda_ver}-cc${cuda_arch}-0"
PROJ_ARCH=arm64

D="${PROJ_NAME}_${PROJ_VER}"
rm -rf "${D}"
mkdir -p "${D}"

rm -rf build
mkdir -p build

install -d ${D}/usr/bin
install -d ${D}/usr/share/gpu-burn
install -m 644 -t ${D}/usr/share/gpu-burn LICENSE

pushd build
cmake .. \
    -DCMAKE_INSTALL_PREFIX="../${D}/usr" \
    -DCMAKE_CUDA_COMPILER="${nvcc_path}" \
    -DCMAKE_CUDA_ARCHITECTURES="${cuda_arch}"
make
make install
popd

# just some CMake object library output voodoo
mv ${D}/usr/share/objects/compare/compare.ptx ${D}/usr/share/gpu-burn/compare.ptx
rm -r ${D}/usr/share/objects

mkdir -p ${D}/DEBIAN
cat >${D}/DEBIAN/control <<-EOF
	Package: ${PROJ_NAME}
	Version: ${PROJ_VER}
	Section: misc
	Priority: optional
	Architecture: ${PROJ_ARCH}
	Depends: cuda-cublas-${cuda_deb_ver}
	Maintainer: Peter Kovac <kovac@photoneo.com>
	Description: Multi-GPU CUDA stress test
	  Continuously performs efficient CUBLAS matrix-matrix multiplication
	  routines to stress test GPU.
EOF

result_dir="../${PROJ_ARCH}"
result_deb="${result_dir}/${PROJ_NAME}_${PROJ_VER}_${PROJ_ARCH}.deb"

mkdir -p "$result_dir"
dpkg-deb --build ${D} "$result_dir"

