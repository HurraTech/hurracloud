SUMMARY = "iCal and scheduling (RFC 2445, 2446, 2447) library"
HOMEPAGE = "https://github.com/libical/libical"
BUGTRACKER = "https://github.com/libical/libical/issues"
LICENSE = "LGPLv2.1 | MPL-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1910a2a76ddf6a9ba369182494170d87 \
                    file://LICENSE.LGPL21.txt;md5=933adb561f159e7c3da079536f0ed871 \
                    file://LICENSE.MPL2.txt;md5=9741c346eef56131163e13b9db1241b3"
SECTION = "libs"

SRC_URI = "https://github.com/${BPN}/${BPN}/releases/download/v${PV}/${BP}.tar.gz"

SRC_URI[md5sum] = "463a59244c6767b8e67b29379405e297"
SRC_URI[sha256sum] = "5c8a21c2b732ece4a33e5c862970b4f35a8548bbcda50de5695f6fc211ac4d97"
UPSTREAM_CHECK_URI = "https://github.com/libical/libical/releases"

inherit cmake pkgconfig

PACKAGECONFIG ??= "icu"
PACKAGECONFIG[bdb] = ",-DCMAKE_DISABLE_FIND_PACKAGE_BDB=True,db"
# ICU is used for RSCALE (RFC7529) support
PACKAGECONFIG[icu] = ",-DCMAKE_DISABLE_FIND_PACKAGE_ICU=True,icu"

# No need to use perl-native, the host perl is sufficient.
EXTRA_OECMAKE += "-DPERL_EXECUTABLE=${HOSTTOOLS_DIR}/perl"

# The glib library can't be cross-compiled, disable for now.
# https://github.com/libical/libical/issues/394
EXTRA_OECMAKE += "-DICAL_GLIB=false"

do_install_append_class-target () {
    # Remove build host references
    sed -i \
       -e 's,${STAGING_LIBDIR},${libdir},g' \
       ${D}${libdir}/cmake/LibIcal/LibIcal*.cmake
}
