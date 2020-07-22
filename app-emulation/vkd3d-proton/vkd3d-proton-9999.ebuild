# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 meson multilib-minimal

EGIT_REPO_URI="https://github.com/HansKristian-Work/vkd3d-proton.git"
IUSE="extras tests"

RDEPEND="
    media-libs/vulkan-loader[${MULTILIB_USEDEP},X]
    app-emulation/wine-staging:=[${MULTILIB_USEDEP}]
    extras? ( x11-libs/xcb-util:=[${MULTILIB_USEDEP}]
        x11-libs/xcb-util-keysyms:=[${MULTILIB_USEDEP}]
        x11-libs/xcb-util-wm:=[${MULTILIB_USEDEP}] )"

DEPEND="
    ${RDEPEND}
    dev-util/spirv-headers
    >=dev-util/vulkan-headers-1.2.140"

DESCRIPTION="Development branches for Proton's Direct3D 12 implementation."
HOMEPAGE="https://github.com/HansKristian-Work/vkd3d-proton/"

LICENSE="LGPL-2.1"
SLOT="0"

multilib_src_configure() {
    local emesonargs=(
        $(meson_use extras enable_extras)
        $(meson_use tests enable_tests)
    )
    meson_src_configure
}

multilib_src_compile() {
    meson_src_compile
}

multilib_src_install() {
    meson_src_install
}
