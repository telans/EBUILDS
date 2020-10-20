# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PLOCALES="ar ast bg ca cs da de el en en_US eo es fa fi fr he hi hr hu it ja ko lt ml nb_NO nl or pa pl pt_BR pt_PT rm ro ru si sk sl sr_RS@cyrillic sr_RS@latin sv ta te th tr uk wa zh_CN zh_TW"
PLOCALE_BACKUP="en"

inherit autotools estack eutils flag-o-matic l10n multilib multilib-minimal pax-utils toolchain-funcs xdg-utils

MY_PN="${PN%%-*}"
MY_P="${MY_PN}-${PV}"

S="${WORKDIR}/${MY_P}"
STAGING_P="wine-staging-${PV}"
STAGING_DIR="${WORKDIR}/${STAGING_P}"
GWP_V="20200523"
PATCHDIR="${WORKDIR}/gentoo-wine-patches"

MAJOR_V=$(ver_cut 1)
SRC_URI="
	patched? ( https://github.com/telans/wine/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz )
	!patched? (
		https://dl.winehq.org/wine/source/${MAJOR_V}.x/${MY_P}.tar.xz
		https://github.com/wine-staging/wine-staging/archive/v${PV}.tar.gz -> ${STAGING_P}.tar.gz )
	https://dev.gentoo.org/~sarnex/distfiles/wine/gentoo-wine-patches-${GWP_V}.tar.xz"
KEYWORDS="~amd64 ~x86"

DESCRIPTION="Free implementation of Windows(tm) on Unix, with Wine-Staging patchset"
HOMEPAGE="https://www.winehq.org/"

LICENSE="LGPL-2.1"
SLOT="${PV}"
IUSE="
	+abi_x86_32 +abi_x86_64 +alsa
	capi cups +custom-cflags
	dos
	elibc_glibc
	+faudio +fontconfig
	+gcrypt +gecko gphoto2 gsm gssapi +gstreamer
	+jpeg
	kerberos
	+lcms ldap
	+mingw +mono +mp3
	ncurses netapi nls
	odbc openal opencl +opengl osmesa oss
	+patched +perl pcap pipelight +png prelink pulseaudio
	+realtime +run-exes
	samba scanner sdl selinux +ssl
	themes +threads +truetype
	udev +udisks +unwind
	v4l +vaapi +vkd3d +vulkan
	+X +xcomposite +xinerama +xml"

REQUIRED_USE="
	|| ( abi_x86_32 abi_x86_64 )
	|| ( X ncurses )
	X? ( truetype )
	elibc_glibc? ( threads )
	osmesa? ( opengl )
	vkd3d? ( vulkan )"

COMMON_DEPEND="
	X? (
		x11-libs/libXcursor[${MULTILIB_USEDEP}]
		x11-libs/libXext[${MULTILIB_USEDEP}]
		x11-libs/libXfixes[${MULTILIB_USEDEP}]
		x11-libs/libXrandr[${MULTILIB_USEDEP}]
		x11-libs/libXi[${MULTILIB_USEDEP}]
		x11-libs/libXxf86vm[${MULTILIB_USEDEP}]
	)
	alsa? ( media-libs/alsa-lib[${MULTILIB_USEDEP}] )
	capi? ( net-libs/libcapi[${MULTILIB_USEDEP}] )
	cups? ( net-print/cups:=[${MULTILIB_USEDEP}] )
	faudio? ( app-emulation/faudio:=[${MULTILIB_USEDEP}] )
	fontconfig? ( media-libs/fontconfig:=[${MULTILIB_USEDEP}] )
	gcrypt? ( dev-libs/libgcrypt:=[${MULTILIB_USEDEP}] )
	gphoto2? ( media-libs/libgphoto2:=[${MULTILIB_USEDEP}] )
	gsm? ( media-sound/gsm:=[${MULTILIB_USEDEP}] )
	gssapi? ( virtual/krb5[${MULTILIB_USEDEP}] )
	gstreamer? (
		media-libs/gstreamer:1.0[${MULTILIB_USEDEP}]
		media-plugins/gst-plugins-meta:1.0[${MULTILIB_USEDEP}]
	)
	jpeg? ( virtual/jpeg:0=[${MULTILIB_USEDEP}] )
	kerberos? ( virtual/krb5:0=[${MULTILIB_USEDEP}] )
	lcms? ( media-libs/lcms:2=[${MULTILIB_USEDEP}] )
	ldap? ( net-nds/openldap:=[${MULTILIB_USEDEP}] )
	mingw? ( cross-i686-w64-mingw32/gcc
		cross-x86_64-w64-mingw32/gcc )
	mp3? ( media-sound/mpg123[${MULTILIB_USEDEP}] )
	ncurses? ( sys-libs/ncurses:0=[${MULTILIB_USEDEP}] )
	netapi? ( net-fs/samba[netapi(+),${MULTILIB_USEDEP}] )
	nls? ( sys-devel/gettext[${MULTILIB_USEDEP}] )
	odbc? ( dev-db/unixODBC:=[${MULTILIB_USEDEP}] )
	openal? ( media-libs/openal:=[${MULTILIB_USEDEP}] )
	opencl? ( virtual/opencl[${MULTILIB_USEDEP}] )
	opengl? (
		virtual/glu[${MULTILIB_USEDEP}]
		virtual/opengl[${MULTILIB_USEDEP}]
	)
	osmesa? ( >=media-libs/mesa-13[osmesa,${MULTILIB_USEDEP}] )
	pcap? ( net-libs/libpcap[${MULTILIB_USEDEP}] )
	png? ( media-libs/libpng:0=[${MULTILIB_USEDEP}] )
	pulseaudio? ( media-sound/pulseaudio[${MULTILIB_USEDEP}] )
	scanner? ( media-gfx/sane-backends:=[${MULTILIB_USEDEP}] )
	sdl? ( media-libs/libsdl2:=[haptic,joystick,${MULTILIB_USEDEP}] )
	ssl? ( net-libs/gnutls:=[${MULTILIB_USEDEP}] )
	sys-apps/attr[${MULTILIB_USEDEP}]
	themes? (
		dev-libs/glib:2[${MULTILIB_USEDEP}]
		x11-libs/cairo[${MULTILIB_USEDEP}]
		x11-libs/gtk+:3[${MULTILIB_USEDEP}]
	)
	truetype? ( media-libs/freetype[${MULTILIB_USEDEP}] )
	udev? ( virtual/libudev:=[${MULTILIB_USEDEP}] )
	udisks? ( sys-apps/dbus[${MULTILIB_USEDEP}] )
	unwind? ( sys-libs/libunwind[${MULTILIB_USEDEP}] )
	v4l? ( media-libs/libv4l[${MULTILIB_USEDEP}] )
	vaapi? ( x11-libs/libva[X,${MULTILIB_USEDEP}] )
	vkd3d? ( app-emulation/vkd3d[${MULTILIB_USEDEP}] )
	vulkan? ( media-libs/vulkan-loader[${MULTILIB_USEDEP}] )
	xcomposite? ( x11-libs/libXcomposite[${MULTILIB_USEDEP}] )
	xinerama? ( x11-libs/libXinerama[${MULTILIB_USEDEP}] )
	xml? (
		dev-libs/libxml2[${MULTILIB_USEDEP}]
		dev-libs/libxslt[${MULTILIB_USEDEP}]
	)"

RDEPEND="
	${COMMON_DEPEND}
	app-emulation/wine-desktop-common
	>app-eselect/eselect-wine-0.3
	!app-emulation/wine:0
	dos? ( games-emulation/dosbox )
	gecko? ( app-emulation/wine-gecko[abi_x86_32?,abi_x86_64?] )
	mono? ( app-emulation/wine-mono )
	perl? (
		dev-lang/perl
		dev-perl/XML-Simple
	)
	pulseaudio? (
		realtime? ( sys-auth/rtkit )
	)
	samba? ( net-fs/samba[winbind] )
	selinux? ( sec-policy/selinux-wine )
	udisks? ( sys-fs/udisks:2 )"

DEPEND="
	${COMMON_DEPEND}
	sys-devel/flex
	>=sys-kernel/linux-headers-2.6
	virtual/pkgconfig
	virtual/yacc
	X? ( x11-base/xorg-proto )
	prelink? ( sys-devel/prelink )
	dev-lang/perl
	dev-perl/XML-Simple
	xinerama? ( x11-base/xorg-proto )"

# These use a non-standard "Wine" category, which is provided by
# /etc/xdg/applications-merged/wine.menu
QA_DESKTOP_FILE="
	usr/share/applications/wine-browsedrive.desktop
	usr/share/applications/wine-notepad.desktop
	usr/share/applications/wine-uninstaller.desktop
	usr/share/applications/wine-winecfg.desktop"

PATCHES=(
	"${PATCHDIR}/patches/${MY_PN}-5.0-winegcc.patch" #260726
	"${PATCHDIR}/patches/${MY_PN}-4.7-multilib-portage.patch" #395615
	"${PATCHDIR}/patches/${MY_PN}-2.0-multislot-apploader.patch" #310611
	"${PATCHDIR}/patches/${MY_PN}-5.9-Revert-makedep-Install-also-generated-typelib-for-in.patch"
)

wine_build_environment_check() {
	[[ ${MERGE_TYPE} = "binary" ]] && return 0

	if use abi_x86_32 && use opencl && [[ "$(eselect opencl show 2> /dev/null)" == "intel" ]]; then
		eerror "You cannot build wine with USE=opencl because intel-ocl-sdk is 64-bit only."
		eerror "See https://bugs.gentoo.org/487864 for more details."
		eerror
		return 1
	fi
}

pkg_pretend() {
	wine_build_environment_check || die
}

pkg_setup() {
	wine_build_environment_check || die

	WINE_VARIANT="${PN#wine}-${PV}"
	WINE_VARIANT="${WINE_VARIANT#-}"

	MY_PREFIX="${EPREFIX}/usr/lib/wine-${WINE_VARIANT}"
	MY_DATAROOTDIR="${EPREFIX}/usr/share/wine-${WINE_VARIANT}"
	MY_DATADIR="${MY_DATAROOTDIR}"
	MY_DOCDIR="${EPREFIX}/usr/share/doc/${PF}"
	MY_INCLUDEDIR="${EPREFIX}/usr/include/wine-${WINE_VARIANT}"
	MY_LIBEXECDIR="${EPREFIX}/usr/libexec/wine-${WINE_VARIANT}"
	MY_LOCALSTATEDIR="${EPREFIX}/var/wine-${WINE_VARIANT}"
	MY_MANDIR="${MY_DATADIR}/man"
}

src_unpack() {
	default
	l10n_find_plocales_changes "${S}/po" "" ".po"
}

src_prepare() {
	local md5="$(md5sum server/protocol.def)"

	if !use patched; then
		local STAGING_EXCLUDE="-W winemenubuilder-Desktop_Icon_Path" #652176
		use pipelight || STAGING_EXCLUDE="${STAGING_EXCLUDE} -W Pipelight"

		# Launch wine-staging patcher in a subshell, using eapply as a backend, and gitapply.sh as a backend for binary patches
		ebegin "Running Wine-Staging patch installer"
		(
			set -- DESTDIR="${S}" --backend=eapply --no-autoconf --all ${STAGING_EXCLUDE}
			cd "${STAGING_DIR}/patches"
			source "${STAGING_DIR}/patches/patchinstall.sh"
		)
		eend $? || die "Failed to apply Wine-Staging patches"
	fi

	default
	eautoreconf

	# Modification of the server protocol requires regenerating the server requests
	if [[ "$(md5sum server/protocol.def)" != "${md5}" ]]; then
		einfo "server/protocol.def was patched; running tools/make_requests"
		tools/make_requests || die #432348
	fi
	sed -i '/^UPDATE_DESKTOP_DATABASE/s:=.*:=true:' tools/Makefile.in || die
	if ! use run-exes; then
		sed -i '/^MimeType/d' loader/wine.desktop || die #117785
	fi

	sed -e "/^Exec=/s/wine /wine-${WINE_VARIANT} /" -i loader/wine.desktop || die
	cp "${PATCHDIR}/files/oic_winlogo.ico" dlls/user32/resources/ || die

	l10n_get_locales > po/LINGUAS || die # otherwise wine doesn't respect LINGUAS

	local f
	for f in loader/*.man.in; do
		cp ${f} ${f/wine/wine64} || die
	done
	# Add wine64 manpages to Makefile
	if use abi_x86_64; then
		sed -i "/wine.man.in/i \
			\\\twine64.man.in \\\\" loader/Makefile.in || die
		sed -i -E 's/(.*wine)(.*\.UTF-8\.man\.in.*)/&\
\164\2/' loader/Makefile.in || die
	fi

	rm_man_file(){
		local file="${1}"
		loc=${2}
		sed -i "/${loc}\.UTF-8\.man\.in/d" "${file}" || die
	}

	while read f; do
		l10n_for_each_disabled_locale_do rm_man_file "${f}"
	done < <(find -name "Makefile.in" -exec grep -q "UTF-8.man.in" "{}" \; -print)
}

src_configure() {
	export LDCONFIG=/bin/true
	use custom-cflags || strip-flags

	multilib-minimal_src_configure
}

multilib_src_configure() {
	local myconf=(
		--prefix="${MY_PREFIX}"
		--datarootdir="${MY_DATAROOTDIR}"
		--datadir="${MY_DATADIR}"
		--docdir="${MY_DOCDIR}"
		--includedir="${MY_INCLUDEDIR}"
		--libdir="${EPREFIX}/usr/$(get_libdir)/wine-${WINE_VARIANT}"
		--libexecdir="${MY_LIBEXECDIR}"
		--localstatedir="${MY_LOCALSTATEDIR}"
		--mandir="${MY_MANDIR}"
		--sysconfdir="${EPREFIX}/etc/wine"
		$(use_with alsa)
		$(use_with capi)
		$(use_with lcms cms)
		$(use_with cups)
		$(use_with ncurses curses)
		$(use_with udisks dbus)
		$(use_with faudio)
		$(use_with fontconfig)
		$(use_with ssl gnutls)
		$(use_enable gecko mshtml)
		$(use_with gcrypt)
		$(use_with gphoto2 gphoto)
		$(use_with gsm)
		$(use_with gssapi)
		$(use_with gstreamer)
		--without-hal
		$(use_with jpeg)
		$(use_with kerberos krb5)
		$(use_with ldap)
		$(use_with mingw) # linux LDFLAGS leak in mingw32: bug #685172
		$(use_enable mono mscoree)
		$(use_with mp3 mpg123)
		$(use_with netapi)
		$(use_with nls gettext)
		$(use_with openal)
		$(use_with opencl)
		$(use_with opengl)
		$(use_with osmesa)
		$(use_with oss)
		$(use_with pcap)
		$(use_with png)
		$(use_with pulseaudio pulse)
		$(use_with threads pthread)
		$(use_with scanner sane)
		$(use_with sdl)
		--without-tests
		$(use_with truetype freetype)
		$(use_with udev)
		$(use_with unwind)
		$(use_with v4l v4l2)
		$(use_with vkd3d)
		$(use_with vulkan)
		$(use_with X x)
		$(use_with X xfixes)
		$(use_with xcomposite)
		$(use_with xinerama)
		$(use_with xml)
		$(use_with xml xslt)
		--with-xattr
		$(use_with themes gtk3)
		$(use_with vaapi va)
	)

	local PKG_CONFIG AR RANLIB
	# Avoid crossdev's i686-pc-linux-gnu-pkg-config if building wine32 on amd64; #472038
	# set AR and RANLIB to make QA scripts happy; #483342
	tc-export PKG_CONFIG AR RANLIB

	if use amd64; then
		if [[ ${ABI} == amd64 ]]; then
			myconf+=( --enable-win64 )
		else
			myconf+=( --disable-win64 )
		fi
	fi

	ECONF_SOURCE=${S} \
	econf "${myconf[@]}"
	emake depend
}

multilib_src_install_all() {
	local DOCS=( ANNOUNCE AUTHORS README )
	add_locale_docs() {
		local locale_doc="documentation/README.$1"
		[[ ! -e ${locale_doc} ]] || DOCS+=( ${locale_doc} )
	}
	l10n_for_each_locale_do add_locale_docs

	einstalldocs
	prune_libtool_files --all

	if ! use perl ; then # winedump calls function_grep.pl, and winemaker is a perl script
		rm "${D%/}${MY_PREFIX}"/bin/{wine{dump,maker},function_grep.pl} \
			"${D%/}${MY_MANDIR}"/man1/wine{dump,maker}.1 || die
	fi

	use abi_x86_32 && pax-mark psmr "${D%/}${MY_PREFIX}"/bin/wine{,-preloader} #255055
	use abi_x86_64 && pax-mark psmr "${D%/}${MY_PREFIX}"/bin/wine64{,-preloader}

	# Avoid double prefix from dosym and make_wrapper
	MY_PREFIX=${MY_PREFIX#${EPREFIX}}

	if use abi_x86_64 && ! use abi_x86_32; then
		dosym wine64 "${MY_PREFIX}"/bin/wine # 404331
		dosym wine64-preloader "${MY_PREFIX}"/bin/wine-preloader
	fi

	# Failglob for binloops, shouldn't be necessary, but including to stay safe
	eshopts_push -s failglob #615218
	# Make wrappers for binaries for handling multiple variants
	# Note: wrappers instead of symlinks because some are shell which use basename
	local b
	for b in "${ED%/}${MY_PREFIX}"/bin/*; do
		make_wrapper "${b##*/}-${WINE_VARIANT}" "${MY_PREFIX}/bin/${b##*/}"
	done
	eshopts_pop
}

pkg_postinst() {
	eselect wine register ${P}
	eselect wine register --staging ${P} || die
	eselect wine update --all || die

	xdg_desktop_database_update
}

pkg_prerm() {
	eselect wine deregister ${P}
	eselect wine deregister --staging ${P} || die
	eselect wine update --all || die
}

pkg_postrm() {
	xdg_desktop_database_update
}
