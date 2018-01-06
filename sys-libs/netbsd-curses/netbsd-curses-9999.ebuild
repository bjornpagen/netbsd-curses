# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 toolchain-funcs

DESCRIPTION="netbsd-libcurses portable edition"
HOMEPAGE="https://github.com/sabotage-linux/netbsd-curses"
SRC_URI=""
EGIT_REPO_URI="https://github.com/sabotage-linux/netbsd-curses"

LICENSE="BSD"
SLOT="0"
IUSE="static-libs"
KEYWORDS="~amd64 ~x86"

RDEPEND="!sys-libs/ncurses"
DEPEND="${RDEPEND}
	sys-devel/make"

src_compile() {
	tc-export AR CC RANLIB
	local BUILD_CC
	tc-export_build_env BUILD_CC
	default
}

src_install() {
	emake PREFIX="${EPREFIX}" DESTDIR="${D}" $(usex static-libs install install-dynlibs)
	dodoc README.md
}
