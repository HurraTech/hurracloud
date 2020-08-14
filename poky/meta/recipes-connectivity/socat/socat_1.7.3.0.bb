SUMMARY = "Multipurpose relay for bidirectional data transfer"
DESCRIPTION = "Socat is a relay for bidirectional data \
transfer between two independent data channels."
HOMEPAGE = "http://www.dest-unreach.org/socat/"

SECTION = "console/network"

DEPENDS = "openssl readline"

LICENSE = "GPL-2.0+-with-OpenSSL-exception"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://README;beginline=257;endline=287;md5=338c05eadd013872abb1d6e198e10a3f"


SRC_URI = "http://www.dest-unreach.org/socat/download/socat-${PV}.tar.bz2 \
           file://Makefile.in-fix-for-parallel-build.patch \
           file://CVE-2016-2217.patch \
"

SRC_URI[md5sum] = "b607edb65bc6c57f4a43f06247504274"
SRC_URI[sha256sum] = "0767e850c0329b9fdf711c6cd468565cbbb28786ba1a8a1cbd5531d4016b3e04"

inherit autotools

EXTRA_AUTORECONF += "--exclude=autoheader"

EXTRA_OECONF += "ac_cv_have_z_modifier=yes sc_cv_sys_crdly_shift=9 \
        sc_cv_sys_tabdly_shift=11 sc_cv_sys_csize_shift=4 \
        ac_cv_ispeed_offset=13 \
        ac_cv_header_bsd_libutil_h=no \
"

PACKAGECONFIG ??= "tcp-wrappers"
PACKAGECONFIG[tcp-wrappers] = "--enable-libwrap,--disable-libwrap,tcp-wrappers"

do_install_prepend () {
    mkdir -p ${D}${bindir}
    install -d ${D}${bindir} ${D}${mandir}/man1
}
