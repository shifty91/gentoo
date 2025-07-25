# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=PLICEASE
DIST_VERSION=1.27
inherit perl-module

DESCRIPTION="Perl implementation of the which utility as an API"

SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x64-solaris"
IUSE="pwhich"

# Was part of File::Which, but depends on File::Which
# so this keeps legacy integrity in place.
PDEPEND="pwhich? ( dev-perl/App-pwhich )"

BDEPEND="
	test? ( >=virtual/perl-Test-Simple-0.470.0 )
"
