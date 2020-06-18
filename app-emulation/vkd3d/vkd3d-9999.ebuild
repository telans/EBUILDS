# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit multilib-minimal autotools git-r3

AUTOTOOLS_AUTORECONF="1"
EGIT_REPO_URI="https://github.com/HansKristian-Work/vkd3d.git"

IUSE="spirv-tools"
RDEPEND="spirv-tools? ( dev-util/spirv-tools:=[${MULTILIB_USEDEP}] )
		media-libs/vulkan-loader[${MULTILIB_USEDEP},X]
		x11-libs/xcb-util:=[${MULTILIB_USEDEP}]
		x11-libs/xcb-util-keysyms:=[${MULTILIB_USEDEP}]
		x11-libs/xcb-util-wm:=[${MULTILIB_USEDEP}]"

DEPEND="${RDEPEND}
		dev-util/spirv-headers
		>=dev-util/vulkan-headers-1.1.129"

DESCRIPTION="D3D12 to Vulkan translation library (development branch)"
HOMEPAGE="https://github.com/HansKristian-Work/vkd3d/"

LICENSE="LGPL-2.1"
SLOT="0"

src_prepare() {
	einfo "echoing ${P}"
	default
	eautoreconf
}

multilib_src_configure() {
	local myconf=(
		$(use_with spirv-tools)
	)

	ECONF_SOURCE=${S} econf "${myconf[@]}"
}
