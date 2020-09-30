SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "CLOSED"

SRC_URI += " \
    git://git@bitbucket.org/aimannajjar/jawhar.git;protocol=ssh \
    file://jawhar.service \
"

SRCREV = "${AUTOREV}"

PV = "1.0"

inherit go systemd

RPROVIDES_${PN} = "jawhar"

S = "${WORKDIR}/git"

SYSTEMD_AUTO_ENABLE_${PN} = "enable"
SYSTEMD_SERVICE_${PN} = "jawhar.service"

GO_IMPORT = "jawhar"

do_compile() {
  cd ${S}/src/jawhar && go build cmd/jawhar/jawhar.go
}

do_install() {
    install -d ${D}${base_bindir} ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/jawhar.service ${D}${systemd_unitdir}/system
    install -m 0755 ${S}/src/jawhar/jawhar ${D}${base_bindir}/jawhar
}

FILES_${PN} += " \
    ${base_bindir}/hurracloud-agent \
    ${systemd_unitdir}/system/hurracloud-agent.service \
"
