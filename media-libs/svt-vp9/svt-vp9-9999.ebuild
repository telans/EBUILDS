# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic cmake-utils

DESCRIPTION="Scalable Video Technology for VP9 (SVT-VP9 Encoder and Decoder)"
HOMEPAGE="https://github.com/OpenVisualCloud/SVT-VP9"

if [ ${PV} = "9999" ]; then
    inherit git-r3
    EGIT_REPO_URI="https://github.com/OpenVisualCloud/SVT-VP9.git"
else
    SRC_URI="https://github.com/OpenVisualCloud/SVT-VP9/archive/v${PV}.tar.gz -> ${P}.tar.gz"
    KEYWORDS="amd64"
fi

LICENSE="BSD-2"
SLOT="0"

DEPEND="dev-lang/nasm"
RDEPEND="${DEPEND}"

S="${WORKDIR}/SVT-VP9-${PV}"

src_prepare() {
    append-ldflags -Wl,-z,noexecstack
    cmake-utils_src_prepare
}

src_configure() {
    cmake-utils_src_configure
}

src_compile() {
    cmake-utils_src_compile
}

src_install() {
    cmake-utils_src_install
}
