# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )
ROCM_VERSION=${PV}

inherit cmake edo flag-o-matic python-any-r1 toolchain-funcs rocm

DESCRIPTION="Basic Linear Algebra Subroutines for sparse computation"
HOMEPAGE="https://github.com/ROCm/rocSPARSE"

SRC_URI="https://github.com/ROCm/rocSPARSE/archive/rocm-${PV}.tar.gz -> rocSPARSE-${PV}.tar.gz
test? (
http://sparse-files.engr.tamu.edu/MM/SNAP/amazon0312.tar.gz -> ${PN}_amazon0312.tar.gz
http://sparse-files.engr.tamu.edu/MM/Muite/Chebyshev4.tar.gz -> ${PN}_Chebyshev4.tar.gz
http://sparse-files.engr.tamu.edu/MM/FEMLAB/sme3Dc.tar.gz -> ${PN}_sme3Dc.tar.gz
http://sparse-files.engr.tamu.edu/MM/Williams/webbase-1M.tar.gz -> ${PN}_webbase-1M.tar.gz
http://sparse-files.engr.tamu.edu/MM/Bova/rma10.tar.gz -> ${PN}_rma10.tar.gz
http://sparse-files.engr.tamu.edu/MM/JGD_BIBD/bibd_22_8.tar.gz -> ${PN}_bibd_22_8.tar.gz
http://sparse-files.engr.tamu.edu/MM/Williams/mac_econ_fwd500.tar.gz -> ${PN}_mac_econ_fwd500.tar.gz
http://sparse-files.engr.tamu.edu/MM/Williams/mc2depi.tar.gz -> ${PN}_mc2depi.tar.gz
http://sparse-files.engr.tamu.edu/MM/Hamm/scircuit.tar.gz -> ${PN}_scircuit.tar.gz
http://sparse-files.engr.tamu.edu/MM/Sandia/ASIC_320k.tar.gz -> ${PN}_ASIC_320k.tar.gz
http://sparse-files.engr.tamu.edu/MM/GHS_psdef/bmwcra_1.tar.gz -> ${PN}_bmwcra_1.tar.gz
http://sparse-files.engr.tamu.edu/MM/HB/nos1.tar.gz -> ${PN}_nos1.tar.gz
http://sparse-files.engr.tamu.edu/MM/HB/nos2.tar.gz -> ${PN}_nos2.tar.gz
http://sparse-files.engr.tamu.edu/MM/HB/nos3.tar.gz -> ${PN}_nos3.tar.gz
http://sparse-files.engr.tamu.edu/MM/HB/nos4.tar.gz -> ${PN}_nos4.tar.gz
http://sparse-files.engr.tamu.edu/MM/HB/nos5.tar.gz -> ${PN}_nos5.tar.gz
http://sparse-files.engr.tamu.edu/MM/HB/nos6.tar.gz -> ${PN}_nos6.tar.gz
http://sparse-files.engr.tamu.edu/MM/HB/nos7.tar.gz -> ${PN}_nos7.tar.gz
http://sparse-files.engr.tamu.edu/MM/DNVS/shipsec1.tar.gz -> ${PN}_shipsec1.tar.gz
http://sparse-files.engr.tamu.edu/MM/Cote/mplate.tar.gz -> ${PN}_mplate.tar.gz
http://sparse-files.engr.tamu.edu/MM/Bai/qc2534.tar.gz -> ${PN}_qc2534.tar.gz
http://sparse-files.engr.tamu.edu/MM/Chevron/Chevron2.tar.gz -> ${PN}_Chevron2.tar.gz
http://sparse-files.engr.tamu.edu/MM/Chevron/Chevron3.tar.gz -> ${PN}_Chevron3.tar.gz
http://sparse-files.engr.tamu.edu/MM/Chevron/Chevron4.tar.gz -> ${PN}_Chevron4.tar.gz
)"

S="${WORKDIR}/rocSPARSE-rocm-${PV}"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"
IUSE="benchmark test"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

RDEPEND="=dev-util/hip-6*
	sci-libs/rocPRIM:${SLOT}"
DEPEND="${RDEPEND}"
BDEPEND="test? (
	dev-cpp/gtest
	>=dev-build/cmake-3.22
	$(python_gen_any_dep 'dev-python/pyyaml[${PYTHON_USEDEP}]')
)
"

RESTRICT="!test? ( test )"

python_check_deps() {
	if use test; then
		python_has_version "dev-python/pyyaml[${PYTHON_USEDEP}]"
	fi
}

src_prepare() {
	# use python interpreter specifyied by python-any-r1
	sed -e "s/\${python}/${EPYTHON}/" \
	    -i clients/tests/CMakeLists.txt || die

	cmake_src_prepare

	# Test need download data from https://sparse-files.engr.tamu.edu (or other mirror site), check MD5,
	# unpack and convert them into csr format
	# This process is handled default by ${S}/cmake/ClientMatrices.cmake, but should be the responsibility of portage.
	if use test; then
		mkdir -p "${BUILD_DIR}"/clients/matrices
		# compile and use the mtx2csr converter. Do not use any optimization flags, because it causes error!
		edo $(tc-getCXX) deps/convert.cpp -o deps/convert
		find "${WORKDIR}" -maxdepth 2 -regextype egrep -regex ".*/(.*)/\1\.mtx" -print0 |
			while IFS= read -r -d '' mtxfile; do
				destination=${BUILD_DIR}/clients/matrices/$(basename -s '.mtx' "${mtxfile}").csr
				ebegin "Converting ${mtxfile} to ${destination}"
				deps/convert "${mtxfile}" "${destination}"
				eend $?
			done
	fi
}

src_configure() {
	rocm_use_hipcc

	# tons of warnings in tests
	append-cxxflags -Wno-explicit-specialization-storage-class

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		-DBUILD_CLIENTS_SAMPLES=OFF
		-DBUILD_FILE_REORG_BACKWARD_COMPATIBILITY=OFF
		-DBUILD_CLIENTS_TESTS=$(usex test ON OFF)
		-DBUILD_CLIENTS_BENCHMARKS=$(usex benchmark ON OFF)
	)

	cmake_src_configure
}

src_test() {
	check_amdgpu
	cd "${BUILD_DIR}/clients/staging" || die
	LD_LIBRARY_PATH="${BUILD_DIR}/library" edob ./rocsparse-test
}

src_install() {
	cmake_src_install

	if use benchmark; then
		cd "${BUILD_DIR}" || die
		dobin clients/staging/rocsparse-bench
	fi
}
