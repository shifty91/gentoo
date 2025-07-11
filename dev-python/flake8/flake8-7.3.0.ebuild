# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( pypy3_11 python3_{11..14} )

inherit distutils-r1

DESCRIPTION="A wrapper around PyFlakes, pep8 & mccabe"
HOMEPAGE="
	https://github.com/PyCQA/flake8/
	https://pypi.org/project/flake8/
"
SRC_URI="
	https://github.com/PyCQA/flake8/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~x64-macos"

RDEPEND="
	=dev-python/pyflakes-3.4*[${PYTHON_USEDEP}]
	=dev-python/pycodestyle-2.14*[${PYTHON_USEDEP}]
"
PDEPEND="
	=dev-python/mccabe-0.7*[${PYTHON_USEDEP}]
"
BDEPEND="
	${RDEPEND}
	test? (
		${PDEPEND}
	)
"

distutils_enable_sphinx docs/source \
	dev-python/sphinx-prompt \
	dev-python/sphinx-rtd-theme
distutils_enable_tests pytest

python_test() {
	local EPYTEST_DESELECT=(
		# fails if additional flake8 plugins are installed
		tests/integration/test_plugins.py::test_local_plugin_can_add_option
	)
	case ${EPYTHON} in
		pypy3*)
			EPYTEST_DESELECT+=(
				# problem from pyflakes:
				# upstream aims only to support long dead pypy3.9
				# https://github.com/PyCQA/pyflakes/issues/779
				# https://github.com/PyCQA/pyflakes/pull/802
				# https://github.com/PyCQA/pyflakes/issues/828
				tests/integration/test_main.py::test_malformed_per_file_ignores_error
				tests/integration/test_main.py::test_tokenization_error_but_not_syntax_error
				tests/integration/test_main.py::test_tokenization_error_is_a_syntax_error
			)
			;;
	esac

	epytest
}
