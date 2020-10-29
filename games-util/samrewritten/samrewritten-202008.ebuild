# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg

DESCRIPTION="Steam Achievement Manager For Linux"
HOMEPAGE="https://github.com/PaulCombal/SamRewritten/"

if [ ${PV} = "9999" ]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/PaulCombal/SamRewritten.git"
else
	SRC_URI="https://github.com/PaulCombal/SamRewritten/archive/${PV}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="+zenity"

S="${WORKDIR}/SamRewritten-${PV}"

DEPEND="
	dev-cpp/gtkmm
	dev-libs/yajl
"
RDEPEND="
	${DEPEND}
	games-util/steam-launcher
	zenity? ( gnome-extra/zenity )
"
