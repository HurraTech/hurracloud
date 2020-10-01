SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "CLOSED"

SRC_URI += " \
    git://git@bitbucket.org/aimannajjar/samaa.git;protocol=ssh \
"

PV = "1.0"
SRCREV = "${AUTOREV}"


DEPENDS_prepend = "nodejs-native "
RPROVIDES_${PN} = "samaa"
RDEPENDS_${PN} = "nginx jawhar"

S = "${WORKDIR}/git"

NPM_ARCH = "x64"

do_compile() {
    export HOME=${WORKDIR}
    npm set cache ${WORKDIR}/npm_cache
    npm cache clear --force
    cd ${S}
	npm --verbose install --production
    npm run-script build
    npm upgrade caniuse-lite browserslist
}


do_install() {
    install -d ${D}/opt/samaa
    cp -R ${S}/build ${D}/opt/samaa/html
	install -m 0644 ${S}/nginx.conf ${D}/opt/samaa/nginx.conf

}

FILES_${PN} += " \
    /opt/samaa \
"
