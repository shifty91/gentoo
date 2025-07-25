# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} python3_{13,14}t pypy3_11 )

inherit distutils-r1 pypi

DESCRIPTION="A fast and thorough lazy object proxy"
HOMEPAGE="
	https://github.com/ionelmc/python-lazy-object-proxy/
	https://pypi.org/project/lazy-object-proxy/
	https://python-lazy-object-proxy.readthedocs.io/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~x64-macos"
IUSE="+native-extensions"

BDEPEND="
	>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest

PATCHES=(
	# https://github.com/ionelmc/python-lazy-object-proxy/pull/79
	"${FILESDIR}/${PN}-1.10.0-pure-tests.patch"
	# https://github.com/ionelmc/python-lazy-object-proxy/pull/88
	"${FILESDIR}/${P}-py314.patch"
)

python_prepare_all() {
	distutils-r1_python_prepare_all

	# No need to benchmark
	sed \
		-e '/benchmark/s:test_:_&:g' \
		-e '/pytest.mark.benchmark/d' \
		-i tests/test_lazy_object_proxy.py || die

	if use native-extensions; then
		unset SETUPPY_FORCE_PURE
	else
		export SETUPPY_FORCE_PURE=1
	fi
}
