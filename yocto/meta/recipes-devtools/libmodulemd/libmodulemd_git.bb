SUMMARY = "C Library for manipulating module metadata files"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=25a3927bff3ee4f5b21bcb0ed3fcd6bb"

SRC_URI = "git://github.com/fedora-modularity/libmodulemd;protocol=https \
           file://0001-spec_tmpl.sh-use-bin-sh-not-usr-bin-sh.patch \
           file://0002-modulemd-v1-meson.build-do-not-generate-gir-or-gtkdo.patch \
           file://0001-v1-meson.build-explicitly-specify-the-v1-library-in-.patch \
           "

PV = "2.6.0"
SRCREV = "7c7f88258491866cdb86d26cadfce37a78f242ec"

S = "${WORKDIR}/git"

inherit meson gobject-introspection

EXTRA_OEMESON = "-Ddeveloper_build=false -Dbuild_api_v1=true -Dbuild_api_v2=true"

DEPENDS += "glib-2.0 libyaml glib-2.0-native python3"

BBCLASSEXTEND = "native nativesdk"

GIR_MESON_OPTION = 'skip_introspection'
GIR_MESON_ENABLE_FLAG = 'false'
GIR_MESON_DISABLE_FLAG = 'true'
