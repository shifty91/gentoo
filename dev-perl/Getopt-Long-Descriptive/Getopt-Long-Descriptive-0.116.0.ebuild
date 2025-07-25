# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=RJBS
DIST_VERSION=0.116
inherit perl-module

DESCRIPTION="Getopt::Long with usage text"

SLOT="0"
KEYWORDS="amd64 arm ~arm64 ppc ~riscv x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos"
IUSE="minimal"

CONFLICTS="!<dev-perl/MooseX-Getopt-0.660.0"

# File::Basename -> perl
# List::Util, Scalar::Util -> perl-Scalar-List-Utils
# Sub::Exporter::Util -> Sub-Exporter
RDEPEND="
	${CONFLICTS}
	virtual/perl-Carp
	>=virtual/perl-Getopt-Long-2.550.0
	>=dev-perl/Params-Validate-0.970.0
	virtual/perl-Scalar-List-Utils
	>=dev-perl/Sub-Exporter-0.972.0
"
BDEPEND="
	${RDEPEND}
	>=virtual/perl-ExtUtils-MakeMaker-6.780.0
	test? (
		!minimal? ( >=virtual/perl-CPAN-Meta-2.120.900 )
		>=dev-perl/CPAN-Meta-Check-0.11.0
		virtual/perl-File-Spec
		dev-perl/Test-Fatal
		>=virtual/perl-Test-Simple-0.960.0
		>=dev-perl/Test-Warnings-0.5.0
	)
"
