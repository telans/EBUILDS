# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7..9} )

inherit bash-completion-r1 check-reqs estack flag-o-matic llvm multiprocessing multilib-build python-any-r1 rust-toolchain toolchain-funcs

ABI_VER="$(ver_cut 1-2)"
SLOT="stable/${ABI_VER}"
MY_P="rustc-${PV}"
SRC="${MY_P}-src.tar.xz"
KEYWORDS="~amd64"
RUST_STAGE0_VERSION=${PV}
DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="https://www.rust-lang.org/"
SRC_URI="
	https://static.rust-lang.org/dist/rustc-${PV}-src.tar.xz -> rustc-${PV}-src.tar.xz
	!system-bootstrap? ( $(rust_arch_uri x86_64-unknown-linux-gnu rust-${RUST_STAGE0_VERSION}) )
"

ALL_LLVM_TARGETS=( AArch64 AMDGPU ARM BPF Hexagon Lanai Mips MSP430
	NVPTX PowerPC RISCV Sparc SystemZ WebAssembly X86 XCore )
ALL_LLVM_TARGETS=( "${ALL_LLVM_TARGETS[@]/#/llvm_targets_}" )
LLVM_TARGET_USEDEPS=${ALL_LLVM_TARGETS[@]/%/?}

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"

IUSE="clippy cpu_flags_x86_sse2 debug doc libressl miri nightly parallel-compiler rls rustfmt system-bootstrap system-llvm wasm ${ALL_LLVM_TARGETS[*]}"

# Please keep the LLVM dependency block separate. Since LLVM is slotted,
# we need to *really* make sure we're not pulling more than one slot
# simultaneously.

# How to use it:
# 1. List all the working slots (with min versions) in ||, newest first.
# 2. Update the := to specify *max* version, e.g. < 11.
# 3. Specify LLVM_MAX_SLOT, e.g. 10.
LLVM_DEPEND="
	|| (
		sys-devel/llvm:10[${LLVM_TARGET_USEDEPS// /,}]
		sys-devel/llvm:9[${LLVM_TARGET_USEDEPS// /,}]
	)
	<sys-devel/llvm-11:=
	wasm? ( sys-devel/lld )
"
LLVM_MAX_SLOT=10

BOOTSTRAP_DEPEND="|| ( >=dev-lang/rust-1.$(($(ver_cut 2) - 1)) >=dev-lang/rust-bin-1.$(($(ver_cut 2) - 1)) )"

COMMON_DEPEND="
	dev-libs/libgit2:=
	net-libs/libssh2:=
	net-libs/http-parser:=
	net-misc/curl:=[ssl]
	sys-libs/zlib:=
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
	elibc_musl? ( sys-libs/libunwind )
	system-llvm? (
		${LLVM_DEPEND}
		>=sys-devel/clang-runtime-8.0[libcxx]
	)
"

DEPEND="${COMMON_DEPEND}
	${PYTHON_DEPS}
	|| (
		>=sys-devel/gcc-8.3
		>=sys-devel/clang-8.0
	)
	system-bootstrap? ( ${BOOTSTRAP_DEPEND}	)
	!system-llvm? (
		dev-util/cmake
		|| ( dev-util/ninja
			dev-util/samurai )
	)
"

RDEPEND="${COMMON_DEPEND}
	>=app-eselect/eselect-rust-20190311
"

REQUIRED_USE="|| ( ${ALL_LLVM_TARGETS[*]} )
	miri? ( nightly )
	parallel-compiler? ( nightly )
	wasm? ( llvm_targets_WebAssembly )
	x86? ( cpu_flags_x86_sse2 )
"

QA_FLAGS_IGNORED="
	usr/bin/.*-${PV}
	usr/lib.*/lib.*.so
	usr/lib/rustlib/.*/codegen-backends/librustc_codegen_llvm-llvm.so
	usr/lib/rustlib/.*/lib/lib.*.so
"

QA_SONAME="
	usr/lib.*/lib.*.so
	usr/lib.*/librustc_macros.*.s
"

# tests need a bit more work, currently they are causing multiple
# re-compilations and somewhat fragile.
RESTRICT="test"

PATCHES=(
	"${FILESDIR}"/0012-Ignore-broken-and-non-applicable-tests.patch
	"${FILESDIR}"/rust-pr71782-Use-a-non-existent-test-path.patch
)

S="${WORKDIR}/${MY_P}-src"

toml_usex() {
	usex "$1" true false
}

pre_build_checks() {
	CHECKREQS_DISK_BUILD="9G"
	eshopts_push -s extglob
	if is-flagq '-g?(gdb)?([1-9])'; then
		CHECKREQS_DISK_BUILD="15G"
	fi
	eshopts_pop
	check-reqs_pkg_setup
}

pkg_pretend() {
	pre_build_checks
}

pkg_setup() {
	pre_build_checks
	python-any-r1_pkg_setup

	# required to link agains system libs, otherwise
	# crates use bundled sources and compile own static version
	export LIBGIT2_SYS_USE_PKG_CONFIG=1
	export LIBSSH2_SYS_USE_PKG_CONFIG=1
	export PKG_CONFIG_ALLOW_CROSS=1

	if use system-llvm; then
		llvm_pkg_setup

		local llvm_config="$(get_llvm_prefix "$LLVM_MAX_SLOT")/bin/llvm-config"

		export LLVM_LINK_SHARED=1
		export RUSTFLAGS="${RUSTFLAGS} -Lnative=$("${llvm_config}" --libdir)"
	fi
}

src_prepare() {
	if ! use system-bootstrap; then
		local rust_stage0_root="${WORKDIR}"/rust-stage0
		local rust_stage0="rust-${RUST_STAGE0_VERSION}-$(rust_abi)"

		"${WORKDIR}/${rust_stage0}"/install.sh --disable-ldconfig \
			--destdir="${rust_stage0_root}" --prefix=/ || die
	fi

	if use system-llvm; then
		rm -rf src/llvm-project/ || die
		# We never enable emscripten.
		rm -rf src/llvm-emscripten/ || die
	fi

	# Remove other unused vendored libraries 
	rm -rf vendor/jemalloc-sys/jemalloc/            
	rm -rf vendor/libz-sys/src/zlib/    
	rm -rf vendor/lzma-sys/xz-*/
	rm -rf vendor/openssl-src/openssl/
	rm -rf vendor/libgit2-sys/libgit2/
	rm -rf vendor/libssh2-sys/libssh2/

	# This only affects the transient rust-installer, but let it use our dynamic xz-libs
	sed -i.lzma -e '/LZMA_API_STATIC/d' src/bootstrap/tool.rs

	# The configure macro will modify some autoconf-related files, which upsets
	# cargo when it tries to verify checksums in those files.  If we just truncate
	# that file list, cargo won't have anything to complain about.
	find vendor -name .cargo-checksum.json \
		-exec sed -i.uncheck -e 's/"files":{[^}]*}/"files":{ }/' '{}' '+'

	# Sometimes Rust sources start with #![...] attributes, and "smart" editors think
	# it's a shebang and make them executable. Then brp-mangle-shebangs gets upset...
	find -name '*.rs' -type f -perm /111 -exec chmod -v -x '{}' '+'

	use libressl && eapply ${FILESDIR}/libressl.patch

	default
}

src_configure() {
	export RUSTFLAGS="-Ctarget-cpu=native -Copt-level=3"
	local rust_target="" rust_targets="" arch_cflags

	# Collect rust target names to compile standard libs for all ABIs.
	for v in $(multilib_get_enabled_abi_pairs); do
		rust_targets="${rust_targets},\"$(rust_abi $(get_abi_CHOST ${v##*.}))\""
	done
	if use wasm; then
		rust_targets="${rust_targets},\"wasm32-unknown-unknown\""
	fi
	rust_targets="${rust_targets#,}"

	local tools="\"cargo\","
	if use clippy; then
		tools="\"clippy\",$tools"
	fi
	if use miri; then
		tools="\"miri\",$tools"
	fi
	if use rls; then
		tools="\"rls\",\"analysis\",\"src\",$tools"
	fi
	if use rustfmt; then
		tools="\"rustfmt\",$tools"
	fi

	local rust_stage0_root
	if use system-bootstrap; then
		rust_stage0_root="$(rustc --print sysroot)"
	else
		rust_stage0_root="${WORKDIR}"/rust-stage0
	fi

	rust_target="$(rust_abi)"

	cat <<- EOF > "${S}"/config.toml
		[llvm]
		optimize = $(toml_usex !debug)
		thin-lto = $(toml_usex system-llvm)
		release-debuginfo = $(toml_usex debug)
		assertions = $(toml_usex debug)
		ninja = true
		targets = "${LLVM_TARGETS// /;}"
		experimental-targets = ""
		link-jobs = $(makeopts_jobs)
		link-shared = $(toml_usex system-llvm)
		use-libcxx = $(toml_usex system-llvm)
		use-linker = "$(usex system-llvm lld)"

		[build]
		build = "${rust_target}"
		host = ["${rust_target}"]
		target = [${rust_targets}]
		cargo = "${rust_stage0_root}/bin/cargo"
		rustc = "${rust_stage0_root}/bin/rustc"
		docs = $(toml_usex doc)
		compiler-docs = $(toml_usex doc)
		submodules = true
		python = "${EPYTHON}"
		locked-deps = false
		vendor = true
		extended = true
		tools = [${tools}]
		verbose = 2
		sanitizers = false
		profiler = false
		cargo-native-static = false
		local-rebuild = false

		[install]
		prefix = "${EPREFIX}/usr"
		libdir = "lib"
		docdir = "share/doc/${PF}"
		mandir = "share/man"

		[rust]
		optimize = true
		debug = $(toml_usex debug)
		codegen-units-std = 1
		debug-assertions = $(toml_usex debug)
		debuginfo-level = 0
		debuginfo-level-rustc = 0
		backtrace = $(toml_usex debug)
		incremental = false
		default-linker = "$(tc-getCC)"
		parallel-compiler = $(toml_usex parallel-compiler)
		channel = "$(usex nightly nightly stable)"
		rpath = false
		verbose-tests = false
		optimize-tests = $(toml_usex !debug)
		codegen-tests = $(toml_usex debug)
		dist-src = $(toml_usex debug)
		lld = $(usex system-llvm false $(toml_usex wasm))
		backtrace-on-ice = true
		jemalloc = false

		[dist]
		src-tarball = false
	EOF

	for v in $(multilib_get_enabled_abi_pairs); do
		rust_target=$(rust_abi $(get_abi_CHOST ${v##*.}))
		arch_cflags="$(get_abi_CFLAGS ${v##*.})"

		cat <<- EOF >> "${S}"/config.env
			CFLAGS_${rust_target}=${arch_cflags}
		EOF

		cat <<- EOF >> "${S}"/config.toml
			[target.${rust_target}]
			cc = "$(tc-getBUILD_CC)"
			cxx = "$(tc-getBUILD_CXX)"
			linker = "$(tc-getCC)"
			ar = "$(tc-getAR)"
		EOF
		# librustc_target/spec/linux_musl_base.rs sets base.crt_static_default = true;
		if use elibc_musl; then
			cat <<- EOF >> "${S}"/config.toml
				crt-static = false
			EOF
		fi
		if use system-llvm; then
			cat <<- EOF >> "${S}"/config.toml
				llvm-config = "$(get_llvm_prefix "${LLVM_MAX_SLOT}")/bin/llvm-config"
			EOF
		fi
	done
	if use wasm; then
		cat <<- EOF >> "${S}"/config.toml
			[target.wasm32-unknown-unknown]
			linker = "$(usex system-llvm lld rust-lld)"
		EOF
	fi

	einfo "Rust configured with the following settings:"
	cat "${S}"/config.toml || die
}

src_compile() {
	env $(cat "${S}"/config.env) RUST_BACKTRACE=1\
		"${EPYTHON}" ./x.py build -vv --config="${S}"/config.toml -j$(makeopts_jobs) || die
}

src_test() {
	export RUSTFLAGS="-Ctarget-cpu=native -Copt-level=3"
	env $(cat "${S}"/config.env) RUST_BACKTRACE=1\
		"${EPYTHON}" ./x.py test -vv --config="${S}"/config.toml -j$(makeopts_jobs) --no-doc --no-fail-fast \
		src/test/codegen \
		src/test/codegen-units \
		src/test/compile-fail \
		src/test/incremental \
		src/test/mir-opt \
		src/test/pretty \
		src/test/run-fail \
		src/test/run-make \
		src/test/run-make-fulldeps \
		src/test/ui \
		src/test/ui-fulldeps || die
}

src_install() {
	export RUSTFLAGS="-Ctarget-cpu=native -Copt-level=3"
	env $(cat "${S}"/config.env) DESTDIR="${D}" \
		"${EPYTHON}" ./x.py install -vv --config="${S}"/config.toml || die

	# bug #689562, #689160
	rm "${D}/etc/bash_completion.d/cargo" || die
	rmdir "${D}"/etc{/bash_completion.d,} || die
	dobashcomp build/tmp/dist/cargo-image/etc/bash_completion.d/cargo

	mv "${ED}/usr/bin/rustc" "${ED}/usr/bin/rustc-${PV}" || die
	mv "${ED}/usr/bin/rustdoc" "${ED}/usr/bin/rustdoc-${PV}" || die
	mv "${ED}/usr/bin/rust-gdb" "${ED}/usr/bin/rust-gdb-${PV}" || die
	mv "${ED}/usr/bin/rust-gdbgui" "${ED}/usr/bin/rust-gdbgui-${PV}" || die
	mv "${ED}/usr/bin/rust-lldb" "${ED}/usr/bin/rust-lldb-${PV}" || die
	mv "${ED}/usr/bin/cargo" "${ED}/usr/bin/cargo-${PV}" || die
	if use clippy; then
		mv "${ED}/usr/bin/clippy-driver" "${ED}/usr/bin/clippy-driver-${PV}" || die
		mv "${ED}/usr/bin/cargo-clippy" "${ED}/usr/bin/cargo-clippy-${PV}" || die
	fi
	if use miri; then
		mv "${ED}/usr/bin/miri" "${ED}/usr/bin/miri-${PV}" || die
		mv "${ED}/usr/bin/cargo-miri" "${ED}/usr/bin/cargo-miri-${PV}" || die
	fi
	if use rls; then
		mv "${ED}/usr/bin/rls" "${ED}/usr/bin/rls-${PV}" || die
	fi
	if use rustfmt; then
		mv "${ED}/usr/bin/rustfmt" "${ED}/usr/bin/rustfmt-${PV}" || die
		mv "${ED}/usr/bin/cargo-fmt" "${ED}/usr/bin/cargo-fmt-${PV}" || die
	fi

	# Move public shared libs to abi specific libdir
	# Private and target specific libs MUST stay in /usr/lib/rustlib/${rust_target}/lib
	if [[ $(get_libdir) != lib ]]; then
		dodir /usr/$(get_libdir)
		mv "${ED}/usr/lib"/*.so "${ED}/usr/$(get_libdir)/" || die
	fi

	dodoc COPYRIGHT
	rm "${ED}/usr/share/doc/${P}"/*.old || die
	rm "${ED}/usr/share/doc/${P}/LICENSE-APACHE" || die
	rm "${ED}/usr/share/doc/${P}/LICENSE-MIT" || die

	# note: eselect-rust adds EROOT to all paths below
	cat <<-EOF > "${T}/provider-${P}"
		/usr/bin/cargo
		/usr/bin/rustdoc
		/usr/bin/rust-gdb
		/usr/bin/rust-gdbgui
		/usr/bin/rust-lldb
	EOF
	if use clippy; then
		echo /usr/bin/clippy-driver >> "${T}/provider-${P}"
		echo /usr/bin/cargo-clippy >> "${T}/provider-${P}"
	fi
	if use miri; then
		echo /usr/bin/miri >> "${T}/provider-${P}"
		echo /usr/bin/cargo-miri >> "${T}/provider-${P}"
	fi
	if use rls; then
		echo /usr/bin/rls >> "${T}/provider-${P}"
	fi
	if use rustfmt; then
		echo /usr/bin/rustfmt >> "${T}/provider-${P}"
		echo /usr/bin/cargo-fmt >> "${T}/provider-${P}"
	fi

	insinto /etc/env.d/rust
	doins "${T}/provider-${P}"
}

pkg_postinst() {
	eselect rust update --if-unset

	elog "Rust installs a helper script for calling GDB and LLDB,"
	elog "for your convenience it is installed under /usr/bin/rust-{gdb,lldb}-${PV}."

	if has_version app-editors/emacs; then
		elog "install app-emacs/rust-mode to get emacs support for rust."
	fi

	if has_version app-editors/gvim || has_version app-editors/vim; then
		elog "install app-vim/rust-vim to get vim support for rust."
	fi

	if use elibc_musl; then
		ewarn "${PN} on *-musl targets is configured with crt-static"
		ewarn ""
		ewarn "you will need to set RUSTFLAGS=\"-C target-feature=-crt-static\" in make.conf"
		ewarn "to use it with portage, otherwise you may see failures like"
		ewarn "error: cannot produce proc-macro for serde_derive v1.0.98 as the target "
		ewarn "x86_64-unknown-linux-musl does not support these crate types"
	fi
}

pkg_postrm() {
	eselect rust cleanup
}
