# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic

DESCRIPTION="Sound card based multimode software modem for Amateur Radio use"
HOMEPAGE="http://www.w1hkj.com"
SRC_URI="https://downloads.sourceforge.net/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="hamlib nls pulseaudio"
IUSE_CPU_FLAGS=" sse sse2 sse3"
IUSE+=" ${IUSE_CPU_FLAGS// / cpu_flags_x86_}"

RDEPEND="x11-libs/fltk:1=[threads(+),xft(+)]
	x11-libs/libX11
	virtual/libudev:=
	media-libs/libsamplerate
	media-libs/libpng:=
	x11-misc/xdg-utils
	dev-perl/RPC-XML
	dev-perl/Term-ReadLine-Perl
	|| (
		media-libs/portaudio[oss]
		media-libs/portaudio[alsa]
	)
	hamlib? ( media-libs/hamlib:= )
	pulseaudio? ( media-libs/libpulse )
	media-libs/libsndfile"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	virtual/pkgconfig"

DOCS=( AUTHORS ChangeLog NEWS README )

PATCHES=( "${FILESDIR}/${PN}-drop-nullptr-definition.patch" )

src_configure() {
	#fails to compile with -flto (bug #860405)
	filter-lto

	append-cxxflags $(test-flags-CXX -std=c++14)
	local myconf=""

	use cpu_flags_x86_sse && myconf="${myconf} --enable-optimizations=sse"
	use cpu_flags_x86_sse2 && myconf="${myconf} --enable-optimizations=sse2"
	use cpu_flags_x86_sse3 && myconf="${myconf} --enable-optimizations=sse3"

	econf ${myconf} \
		--with-sndfile \
		$(use_with hamlib) \
		$(use_enable nls) \
		$(use_with pulseaudio) \
		--without-asciidoc
}
