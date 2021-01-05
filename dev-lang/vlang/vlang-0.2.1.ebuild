# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

VC_SHA="563c3bd5720e513326fbac728dde29454275de9d" #  [v:master] e26a690 - 0.2.1

DESCRIPTION="Simple, fast, safe compiled language for developing maintainable software."
HOMEPAGE="https://vlang.io"
SRC_URI="
    https://github.com/vlang/v/archive/${PV}.tar.gz -> ${P}.tar.gz
    https://github.com/vlang/vc/archive/${VC_SHA}.tar.gz -> vc-${PV}.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}/v-${PV}"

src_prepare() {
    default
    cp "${FILESDIR}"/Makefile . || die
}

src_compile() {
    emake VC="${WORKDIR}"/vc-${VC_SHA}
}

src_install() {
    exeinto /usr/share/vlang
    doexe v
    dosym /usr/share/vlang/v /usr/bin/v
    insinto /usr/share/vlang
    doins -r cmd
    dodoc -r doc
    einstalldocs
}
