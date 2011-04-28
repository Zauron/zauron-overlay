# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=2
PYTHON_DEPEND="3:3.2"
inherit eutils multilib python cmake-utils

IUSE="blender-game bullet ffmpeg fftw jack jpeg2k nls openexr openal openmp sndfile tiff"

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org/"
SRC_URI="http://download.blender.org/source/${P}.tar.gz"

SLOT="0"
LICENSE="|| ( GPL-2 BL BSD )"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-cpp/eigen
	media-libs/glew
	media-libs/libpng
	media-libs/libsamplerate
	>=media-libs/libsdl-1.2
	virtual/jpeg
	virtual/opengl
	blender-game? ( >=media-libs/libsdl-1.2[joystick] )
	bullet? ( sci-physics/bullet )
	ffmpeg? ( >=media-video/ffmpeg-0.5[encode,theora] )
	fftw? ( sci-libs/fftw )
	jack? ( media-sound/jack )
	jpeg2k? ( media-libs/openjpeg )
	nls? ( >=media-libs/freetype-2.0
		virtual/libintl
		>=media-libs/ftgl-2.1 )
	openal? ( >=media-libs/openal-1.6.372
		>=media-libs/freealut-1.1.0-r1 )
	openexr? ( media-libs/openexr )
	sndfile? ( media-libs/libsndfile )
	tiff? ( media-libs/tiff )"
DEPEND="${RDEPEND}
	sys-devel/gcc[openmp?]
	x11-base/xorg-server"

pkg_setup() {
	mycmakeargs=(
		$(cmake-utils_use_with blender-game GAMEENGINE)
		$(cmake-utils_use_with blender-game PLAYER)
		$(cmake-utils_use_with bullet)
		$(cmake-utils_use_with ffmpeg)
		$(cmake-utils_use_with fftw FFTW3)
		$(cmake-utils_use_with jpeg2k OPENJPEG)
		$(cmake-utils_use jpeg2k OPENJPEG /usr)
		$(cmake-utils_use jpeg2k OPENJPEG_INC \${OPENJPEG}/include)
		$(cmake-utils_use jpeg2k OPENJPEG_LIb \${OPENJPEG}/$(get_libdir))
		$(cmake-utils_use_with nls INTERNATIONAL)
		$(cmake-utils_use_with openal)
		$(cmake-utils_use_with openexr)
		$(cmake-utils_use_with openmp)
		$(cmake-utils_use_with sndfile)
		$(cmake-utils_use_with tiff)
		-DWITH_LZO=OFF
		-DWITH_LZMA=OFF
	)
}

src_prepare() {
	return
	# TODO remove bundled libs
	rm -r extern/{bullet2,Eigen2,glew,libopenjpeg,libredcode,lzma,lzo} || die
	sed -i -e '/ADD_SUBDIRECTORY(extern)/d' \
		CMakeLists.txt || die
	find . -name 'CMakeLists.txt' -exec sed -i -e \
		'/extern\/glew/s:\.*extern/glew:/usr/include:g' {} \; || die
	epatch "${FILESDIR}"/${P}-glew.patch
	epatch "${FILESDIR}"/${P}-eigen.patch
}

pkg_preinst(){
	if [ -h "${ROOT}/usr/$(get_libdir)/blender/plugins/include" ];
	then
		rm -f "${ROOT}"/usr/$(get_libdir)/blender/plugins/include
	fi
}

pkg_postinst(){
	elog "blender uses python integration.  As such, may have some"
	elog "inherit risks with running unknown python scripting."
	elog " "
	elog "CVE-2008-1103-1.patch has been removed as it interferes"
	elog "with autosave undo features. Up stream blender coders"
	elog "have not addressed the CVE issue as the status is still"
	elog "a CANDIDATE and not CONFIRMED."
	elog " "
	elog "It is recommended to change your blender temp directory"
	elog "from /tmp to ~tmp or another tmp file under your home"
	elog "directory. This can be done by starting blender, then"
	elog "dragging the main menu down do display all paths."
}
