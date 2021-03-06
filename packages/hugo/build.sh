TERMUX_PKG_HOMEPAGE=https://gohugo.io/
TERMUX_PKG_DESCRIPTION="A fast and flexible static site generator"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_VERSION=0.54.0
TERMUX_PKG_SHA256=fe0f4d4542491706cc19cb8c0acd63f1d9989cfbeaaad39d93031e91bf73fd91
TERMUX_PKG_SRCURL=https://github.com/gohugoio/hugo/archive/v$TERMUX_PKG_VERSION.tar.gz

termux_step_make() {
	termux_setup_golang
	export GOPATH=$TERMUX_PKG_BUILDDIR
	export CGO_LDFLAGS="-L$TERMUX_PREFIX/lib"

	cd $TERMUX_PKG_SRCDIR
	go build \
		-o "$TERMUX_PREFIX/bin/hugo" \
		-tags extended \
		main.go

	# Building for host to generate manpages and completion.
	chmod 700 -R $GOPATH/pkg && rm -rf $GOPATH/pkg
	unset GOOS GOARCH CGO_LDFLAGS
	unset CC CXX CFLAGS CXXFLAGS LDFLAGS
	go build \
		-o "$TERMUX_PKG_BUILDDIR/hugo" \
		-tags extended \
		main.go
}

termux_step_make_install() {
	mkdir -p $TERMUX_PREFIX/share/{bash-completion/completions,man/man1}

	$TERMUX_PKG_BUILDDIR/hugo gen autocomplete \
		--completionfile=$TERMUX_PREFIX/share/bash-completion/completions/hugo
	$TERMUX_PKG_BUILDDIR/hugo gen man \
		--dir=$TERMUX_PREFIX/share/man/man1/

	# Seems that some files became RO-only
	# and should be manually removed.
	chmod 700 -R $GOPATH/pkg && rm -rf $GOPATH/pkg
}
