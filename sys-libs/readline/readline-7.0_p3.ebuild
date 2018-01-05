# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit eutils multilib toolchain-funcs flag-o-matic multilib-minimal

# Official patches
# See ftp://ftp.cwru.edu/pub/bash/readline-7.0-patches/
PLEVEL=${PV##*_p}
MY_PV=${PV/_p*}
MY_PV=${MY_PV/_/-}
MY_P=${PN}-${MY_PV}
[[ ${PV} != *_p* ]] && PLEVEL=0
patches() {
	[[ ${PLEVEL} -eq 0 ]] && return 1
	local opt=$1
	eval set -- {1..${PLEVEL}}
	set -- $(printf "${PN}${MY_PV/\.}-%03d " "$@")
	if [[ ${opt} == -s ]] ; then
		echo "${@/#/${DISTDIR}/}"
	else
		local u
		for u in ftp://ftp.cwru.edu/pub/bash mirror://gnu/${PN} ; do
			printf "${u}/${PN}-${MY_PV}-patches/%s " "$@"
		done
	fi
}

DESCRIPTION="Another cute console display library"
HOMEPAGE="http://cnswww.cns.cwru.edu/php/chet/readline/rltop.html"
case ${PV} in
*_alpha*|*_beta*|*_rc*) SRC_URI+=" ftp://ftp.cwru.edu/pub/bash/${MY_P}.tar.gz" ;;
*) SRC_URI="mirror://gnu/${PN}/${MY_P}.tar.gz $(patches)" ;;
esac

LICENSE="GPL-3"
SLOT="0/7"  # subslot matches SONAME major
KEYWORDS="~alpha amd64 ~arm ~arm64 hppa ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh sparc x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux"
IUSE="static-libs utils"

RDEPEND="virtual/curses:0=[static-libs?,${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${MY_P}.tar.gz
}

src_prepare() {
	[[ ${PLEVEL} -gt 0 ]] && epatch $(patches -s)
	epatch "${FILESDIR}"/${PN}-5.0-no_rpath.patch
	epatch "${FILESDIR}"/${PN}-6.2-rlfe-tgoto.patch #385091
	epatch "${FILESDIR}"/${PN}-7.0-headers.patch
	epatch "${FILESDIR}"/${PN}-7.0-missing-echo-proto.patch

	ln -s ../.. examples/rlfe/readline # for local readline headers
}

src_configure() {
	# fix implicit decls with widechar funcs
	append-cppflags -D_GNU_SOURCE
	# https://lists.gnu.org/archive/html/bug-readline/2010-07/msg00013.html
	append-cppflags -Dxrealloc=_rl_realloc -Dxmalloc=_rl_malloc -Dxfree=_rl_free

	# Make sure configure picks a better ar than `ar`. #484866
	export ac_cv_prog_AR=$(tc-getAR)

	# Force the test since we used sed above to force it.
	export bash_cv_termcap_lib=curses

	# Control cross-compiling cases when we know the right answer.
	# In cases where the C library doesn't support wide characters, readline
	# itself won't work correctly, so forcing the answer below should be OK.
	if tc-is-cross-compiler ; then
		export bash_cv_func_sigsetjmp='present'
		export bash_cv_func_ctype_nonascii='yes'
		export bash_cv_wcwidth_broken='no' #503312
	fi

	# This is for rlfe, but we need to make sure LDFLAGS doesn't change
	# so we can re-use the config cache file between the two.
	append-ldflags -L.

	multilib-minimal_src_configure
}

multilib_src_configure() {
	ECONF_SOURCE=${S} \
	econf \
		--cache-file="${BUILD_DIR}"/config.cache \
		--docdir='$(datarootdir)'/doc/${PF} \
		--with-curses \
		$(use_enable static-libs static)

	if use utils && multilib_is_native_abi && ! tc-is-cross-compiler ; then
		# code is full of AC_TRY_RUN()
		mkdir -p examples/rlfe || die
		cd examples/rlfe || die
		ECONF_SOURCE=${S}/examples/rlfe \
		econf --cache-file="${BUILD_DIR}"/config.cache
	fi
}

multilib_src_compile() {
	emake

	if use utils && multilib_is_native_abi && ! tc-is-cross-compiler ; then
		# code is full of AC_TRY_RUN()
		cd examples/rlfe || die
		local l
		for l in readline history ; do
			ln -s ../../shlib/lib${l}$(get_libname)* lib${l}$(get_libname)
			ln -sf ../../lib${l}.a lib${l}.a
		done
		emake
	fi
}

multilib_src_install() {
	default

	if multilib_is_native_abi ; then
		gen_usr_ldscript -a readline history #4411

		if use utils && ! tc-is-cross-compiler; then
			dobin examples/rlfe/rlfe
		fi
	fi
}

multilib_src_install_all() {
	einstalldocs
	dodoc USAGE
	dohtml -r doc/.
	docinto ps
	dodoc doc/*.ps
}
pkg_preinst() {
	# bug #29865
	# Reappeared in #595324 with paludis so keeping this for now...
	preserve_old_lib /$(get_libdir)/lib{history,readline}.so.{4,5,6}
}

pkg_postinst() {
	preserve_old_lib_notify /$(get_libdir)/lib{history,readline}.so.{4,5,6}
}