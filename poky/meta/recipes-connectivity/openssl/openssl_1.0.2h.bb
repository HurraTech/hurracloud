require openssl.inc

# For target side versions of openssl enable support for OCF Linux driver
# if they are available.
DEPENDS += "cryptodev-linux"

CFLAG += "-DHAVE_CRYPTODEV -DUSE_CRYPTODEV_DIGESTS"

LIC_FILES_CHKSUM = "file://LICENSE;md5=27ffa5d74bb5a337056c14b2ef93fbf6"

export DIRS = "crypto ssl apps engines"
export OE_LDFLAGS="${LDFLAGS}"

SRC_URI += "file://configure-targets.patch \
            file://shared-libs.patch \
            file://oe-ldflags.patch \
            file://engines-install-in-libdir-ssl.patch \
            file://debian1.0.2/block_diginotar.patch \
            file://debian1.0.2/block_digicert_malaysia.patch \
            file://debian/ca.patch \
            file://debian/c_rehash-compat.patch \
            file://debian/debian-targets.patch \
            file://debian/man-dir.patch \
            file://debian/man-section.patch \
            file://debian/no-rpath.patch \
            file://debian/no-symbolic.patch \
            file://debian/pic.patch \
            file://debian1.0.2/version-script.patch \
            file://openssl_fix_for_x32.patch \
            file://fix-cipher-des-ede3-cfb1.patch \
            file://openssl-avoid-NULL-pointer-dereference-in-EVP_DigestInit_ex.patch \
            file://find.pl \
            file://openssl-fix-des.pod-error.patch \
            file://Makefiles-ptest.patch \
            file://ptest-deps.patch \
            file://run-ptest \
            file://crypto_use_bigint_in_x86-64_perl.patch \
            file://openssl-1.0.2a-x32-asm.patch \
            file://ptest_makefile_deps.patch  \
            file://parallel.patch \
            file://CVE-2016-2177.patch \
            file://CVE-2016-2178.patch \
            file://CVE-2016-2180.patch \
            file://CVE-2016-2181_p1.patch \
            file://CVE-2016-2181_p2.patch \
            file://CVE-2016-2181_p3.patch \
            file://CVE-2016-2182.patch \
            file://CVE-2016-6302.patch \
            file://CVE-2016-6303.patch \
            file://CVE-2016-6304.patch \
            file://CVE-2016-6306.patch \
            file://CVE-2016-2179.patch \
            file://CVE-2016-8610.patch \
           "

SRC_URI[md5sum] = "9392e65072ce4b614c1392eefc1f23d0"
SRC_URI[sha256sum] = "1d4007e53aad94a5b2002fe045ee7bb0b3d98f1a47f8b2bc851dcd1c74332919"

PACKAGES =+ " \
	${PN}-engines \
	${PN}-engines-dbg \
	"

FILES_${PN}-engines = "${libdir}/ssl/engines/*.so ${libdir}/engines"
FILES_${PN}-engines-dbg = "${libdir}/ssl/engines/.debug"

PARALLEL_MAKE = ""
PARALLEL_MAKEINST = ""

do_configure_prepend() {
  cp ${WORKDIR}/find.pl ${S}/util/find.pl
}

# The crypto_use_bigint patch means that perl's bignum module needs to be
# installed, but some distributions (for example Fedora 23) don't ship it by
# default.  As the resulting error is very misleading check for bignum before
# building.
do_configure_prepend() {
	if ! perl -Mbigint -e true; then
		bbfatal "The perl module 'bignum' was not found but this is required to build openssl.  Please install this module (often packaged as perl-bignum) and re-run bitbake."
	fi
}
