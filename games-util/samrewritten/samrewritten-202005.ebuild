# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop xdg-utils

DESCRIPTION="Steam Achievement Manager For Linux"
HOMEPAGE="https://github.com/PaulCombal/SamRewritten/"

SRC_URI="https://github.com/PaulCombal/${PN}/archive/${PV}.tar.gz"

LICENSE="GPL-3.0"
SLOT="0"
KEYWORDS="amd64"
IUSE="+zenity"

S="${WORKDIR}/SamRewritten-${PV}"

DEPEND="dev-cpp/gtkmm
        dev-libs/yajl"
RDEPEND="${DEPEND}
         games-util/steam-launcher
         zenity? ( gnome-extra/zenity )"

PATCHES=("${FILESDIR}/make-install.patch")

src_prepare() {
    default
}

src_install() {
    emake DESTDIR=${D} install
    newicon -s 64 assets/icon_64.png samrewritten.png
    newicon -s 256 assets/icon_64.png samrewritten.png
    domenu package/samrewritten.desktop
}

pkg_postinst() {
	xdg_desktop_database_update
    xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
    xdg_icon_cache_update
}
