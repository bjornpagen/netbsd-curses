# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Virtual for curses"
SLOT="0"
IUSE="unicode static-libs"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"

RDEPEND="|| ( sys-libs/ncurses:0=[unicode?,static-libs?]
			sys-libs/netbsd-curses:0=[static-libs?] )"
