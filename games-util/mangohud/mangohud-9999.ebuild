# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit distutils-r1 meson multilib-minimal

DESCRIPTION="A Vulkan and OpenGL overlay for monitoring FPS, CPU/GPU load and more."
HOMEPAGE="https://github.com/flightlessmango/MangoHud"

if [ ${PV} = "9999" ]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/flightlessmango/MangoHud.git"
else
	SRC_URI="https://github.com/flightlessmango/${PN}/archive/v${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/MangoHud-${PV}"
fi

LICENSE="MIT"
SLOT="0"
IUSE="+dbus debug +X xnvctrl wayland video_cards_nvidia"
REQUIRED_USE="
	^^ ( X wayland )
	xnvctrl? ( video_cards_nvidia )"

BDEPEND="dev-python/mako[${PYTHON_USEDEP}]"
DEPEND="
	dev-util/glslang
	>=dev-util/vulkan-headers-1.2
	media-libs/vulkan-loader[${MULTILIB_USEDEP}]
	media-libs/libglvnd[$MULTILIB_USEDEP]
	dbus? ( sys-apps/dbus[${MULTILIB_USEDEP}] )
	X? ( x11-libs/libX11[${MULTILIB_USEDEP}] )
	video_cards_nvidia? (
		x11-drivers/nvidia-drivers[${MULTILIB_USEDEP}]
		xnvctrl? ( x11-drivers/nvidia-drivers[static-libs] )
	)
	wayland? ( dev-libs/wayland[${MULTILIB_USEDEP}] )"
RDEPEND="${DEPEND}"

src_prepare() {
	default
}

multilib_src_configure() {
	local emesonargs=(
		-Duse_system_vulkan=enabled
		-Dappend_libdir_mangohud=false
		-Dinclude_doc=false
		-Dwith_nvml=disabled
		-Dwith_xnvctrl=$(usex xnvctrl enabled disabled)
		-Dwith_x11=$(usex X enabled disabled)
		-Dwith_wayland=$(usex wayland enabled disabled)
		-Dwith_dbus=$(usex dbus enabled disabled)
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}

multilib_src_install_all() {
	dodoc "${S}/bin/MangoHud.conf"
	einstalldocs
}
