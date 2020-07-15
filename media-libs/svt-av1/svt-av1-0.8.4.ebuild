# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic cmake-utils

DESCRIPTION="Scalable Video Technology for AV1 (SVT-AV1 Encoder and Decoder)"
HOMEPAGE="https://github.com/OpenVisualCloud/SVT-AV1"
SRC_URI="https://github.com/OpenVisualCloud/SVT-AV1/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="ffmpeg"

DEPEND="dev-lang/nasm"
RDEPEND="${DEPEND}
    ffmpeg? ( >=media-video/ffmpeg-4.2.4[encode,svt_av1] )"

S="${WORKDIR}/SVT-AV1-${PV}"

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
