TERMUX_PKG_HOMEPAGE=https://www.erlang.org/
TERMUX_PKG_DESCRIPTION="General-purpose concurrent functional programming language"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=22.3.4.22
TERMUX_PKG_SRCURL=https://github.com/erlang/otp/archive/OTP-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=dd306ac9987bbe80b20bf1efc8f94b7d6c0248c9fcb2dc761580c2c28d06cfba
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_AUTO_UPDATE_TAG_REGEXP="\d+(\.\d+)+"
TERMUX_PKG_DEPENDS="openssl, ncurses, zlib"
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--without-javac --with-ssl=${TERMUX_PREFIX} --with-termcap"
TERMUX_PKG_EXTRA_MAKE_ARGS="noboot"

termux_step_post_get_source() {
	# We need a host build every time:
	rm -Rf "$TERMUX_PKG_HOSTBUILD_DIR"
	./otp_build autoconf
}

termux_step_host_build() {
	cd $TERMUX_PKG_SRCDIR
	./configure --enable-bootstrap-only
	make -j "$TERMUX_MAKE_PROCESSES"
}

termux_step_pre_configure() {
	(cd erts && autoreconf)

	# liblog is needed for syslog usage:
	LDFLAGS+=" -llog"
	# Put binaries built in termux_step_host_build at start of PATH:
	cp bin/*/* $TERMUX_PKG_SRCDIR/bootstrap/bin
	export PATH="$TERMUX_PKG_SRCDIR/bootstrap/bin:$PATH"
}
