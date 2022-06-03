# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit rpm

HOMEPAGE="https://github.com/KSP-CKAN/CKAN/"
SRC_URI="https://github.com/KSP-CKAN/CKAN/releases/download/v${PV}/ckan-${PV}-1.noarch.rpm -> ${P}.rpm"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="dev-lang/mono"

S="${WORKDIR}"

src_install() {
    insinto "/usr/lib64/ckan"
    dobin "${FILESDIR}/ckan"
    doins "usr/lib/ckan/ckan.exe"
}
