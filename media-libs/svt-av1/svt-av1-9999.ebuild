# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic cmake

DESCRIPTION="Scalable Video Technology for AV1 (SVT-AV1 Encoder and Decoder)"
HOMEPAGE="https://github.com/OpenVisualCloud/SVT-AV1"

if [ ${PV} = "9999" ]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/OpenVisualCloud/SVT-AV1.git"
else
	SRC_URI="https://github.com/OpenVisualCloud/SVT-AV1/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 -x86" # -x86: https://github.com/OpenVisualCloud/SVT-AV1/issues/1231
	S="${WORKDIR}/SVT-AV1-${PV}"
fi

LICENSE="BSD-2"
IUSE="debug"
SLOT="0/0.8.4"

src_prepare() {
	append-ldflags -Wl,-z,noexecstack
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=$(usex debug Debug Release)
		-DBUILD_TESTING=False # Requires cloning https://github.com/Cidana-Developers/aom.git/
	)

	cmake_src_configure
}
