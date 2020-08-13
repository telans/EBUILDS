# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit eutils

DESCRIPTION="Common files shared between multiple slots of .NET Core"
HOMEPAGE="https://www.microsoft.com/net/core"
LICENSE="MIT"

SRC_URI="https://download.visualstudio.microsoft.com/download/pr/4f9b8a64-5e09-456c-a087-527cfc8b4cd2/15e14ec06eab947432de139f172f7a98/dotnet-sdk-3.1.401-linux-x64.tar.gz"

SLOT="0"
KEYWORDS="~amd64"

QA_PREBUILT="*"
RESTRICT="splitdebug"

RDEPEND="
    ~dev-dotnet/dotnetcore-sdk-bin-${PV}
    !dev-dotnet/dotnetcore-sdk-bin:0"

S=${WORKDIR}

src_prepare() {
    default
    find . -maxdepth 1 -type d ! -name . ! -name packs -exec rm -rf {} \; || die
    find ./packs -maxdepth 1 -type d ! -name packs ! -name NETStandard.Library.Ref -exec rm -rf {} \; || die
}

src_install() {
    local dest="opt/dotnet_core"
    dodir "${dest}"

    local ddest="${D}/${dest}"
    cp -a "${S}"/* "${ddest}/" || die
    dosym "/${dest}/dotnet" "/usr/bin/dotnet"

    echo -n "DOTNET_ROOT=/${dest}" > "${T}/90dotnet"
    doenvd "${T}/90dotnet"
}