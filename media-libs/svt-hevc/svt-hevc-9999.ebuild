# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic cmake

DESCRIPTION="Scalable Video Technology for HEVC (SVT-HEVC Encoder)"
HOMEPAGE="https://github.com/OpenVisualCloud/SVT-HEVC"

if [ ${PV} = "9999" ]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/OpenVisualCloud/SVT-HEVC.git"
else
	SRC_URI="https://github.com/OpenVisualCloud/SVT-HEVC/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/SVT-HEVC-${PV}"
fi

LICENSE="BSD-2"
IUSE="debug"
SLOT="0"

DEPEND="dev-lang/nasm"
RDEPEND="${DEPEND}"

src_prepare() {
	append-ldflags -Wl,-z,noexecstack
	cmake_src_prepare
}

src_configure() {
	use debug && CMAKE_BUILD_TYPE=Debug
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
}

src_install() {
	cmake_src_install
}
