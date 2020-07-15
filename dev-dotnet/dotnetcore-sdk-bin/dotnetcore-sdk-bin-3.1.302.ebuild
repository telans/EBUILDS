# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit eutils

DESCRIPTION=".NET Core SDK - binary precompiled for glibc"
HOMEPAGE="https://www.microsoft.com/net/core"
LICENSE="MIT"

SRC_URI="https://download.visualstudio.microsoft.com/download/pr/c1a30ceb-adc2-4244-b24a-06ca29bb1ee9/6df5d856ff1b3e910d283f89690b7cae/dotnet-sdk-3.1.302-linux-x64.tar.gz"

SLOT="3.1"
KEYWORDS="~amd64"

QA_PREBUILT="*"
RESTRICT="splitdebug"

# The sdk includes the runtime-bin and aspnet-bin so prevent from installing at the same time
# dotnetcore-sdk is the source based build
IUSE="libressl"

RDEPEND="
    >=dev-dotnet/dotnetcore-sdk-bin-common-${PV}
    >=sys-apps/lsb-release-1.4
    >=sys-devel/llvm-4.0
    >=dev-util/lldb-4.0
    >=sys-libs/libunwind-1.1-r1
    >=dev-libs/icu-57.1
    >=dev-util/lttng-ust-2.8.1
    !libressl? ( dev-libs/openssl:0= )
    libressl? ( dev-libs/libressl:0= )
    >=net-misc/curl-7.49.0
    >=app-crypt/mit-krb5-1.14.2
    >=sys-libs/zlib-1.2.8-r1
    !dev-dotnet/dotnetcore-sdk
    !dev-dotnet/dotnetcore-sdk-bin:0
    !dev-dotnet/dotnetcore-runtime-bin
    !dev-dotnet/dotnetcore-aspnet-bin"

S=${WORKDIR}

src_prepare() {
    default
    find . -maxdepth 1 -type f -exec rm -f {} \; || die
    rm -rf ./packs/NETStandard.Library.Ref || die
}

src_install() {
    local dest="opt/dotnet_core"
    dodir "${dest}"

    local ddest="${D}/${dest}"
    cp -a "${S}"/* "${ddest}/" || die
}
