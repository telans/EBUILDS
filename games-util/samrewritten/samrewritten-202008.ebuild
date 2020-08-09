# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop xdg-utils

DESCRIPTION="Steam Achievement Manager For Linux"
HOMEPAGE="https://github.com/PaulCombal/SamRewritten/"

if [ ${PV} = "9999" ]; then
    inherit git-r3
    EGIT_REPO_URI="https://github.com/PaulCombal/SamRewritten.git"
else
    SRC_URI="https://github.com/PaulCombal/${PN}/archive/${PV}.tar.gz"
    KEYWORDS="amd64 x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="+zenity"

S="${WORKDIR}/SamRewritten-${PV}"

DEPEND="
    dev-cpp/gtkmm:*
    dev-libs/yajl"

RDEPEND="
    ${DEPEND}
    games-util/steam-launcher
    zenity? ( gnome-extra/zenity )"

src_prepare() {
    default
}

src_install() {
    emake LIBDIR=lib64 DESTDIR=${D} install
}

pkg_postinst() {
    xdg_desktop_database_update
    xdg_icon_cache_update
}

pkg_postrm() {
    xdg_desktop_database_update
    xdg_icon_cache_update
}
