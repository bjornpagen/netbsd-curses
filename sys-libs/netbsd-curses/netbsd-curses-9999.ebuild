# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="netbsd-libcurses portable edition"
HOMEPAGE="https://github.com/sabotage-linux/netbsd-curses"
SRC_URI=""
EGIT_REPO_URI="https://github.com/sabotage-linux/netbsd-curses"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="!sys-libs/ncurses"
DEPEND="${RDEPEND}
	sys-devel/make"

src_install() {
	emake DESTDIR="${D}" install
	dodoc README.md
}
