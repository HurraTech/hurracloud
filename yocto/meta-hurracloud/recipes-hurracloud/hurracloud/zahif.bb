SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "CLOSED"

SRC_URI += " \
    git://git@bitbucket.org/aimannajjar/zahif.git;protocol=ssh \
    file://zahif.service \
"

SRCREV = "${AUTOREV}"

PV = "1.0"

inherit go systemd

RPROVIDES_${PN} = "zahif"
DEPENDS = "leveldb"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

SYSTEMD_AUTO_ENABLE_${PN} = "enable"
SYSTEMD_SERVICE_${PN} = "zahif.service"

GO_IMPORT = "zahif"

do_compile() {
  cd ${S}/src/zahif && go build cmd/zahif/zahif.go
}

do_install() {
    install -d ${D}${base_bindir} ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/zahif.service ${D}${systemd_unitdir}/system
    install -m 0755 ${S}/src/zahif/zahif ${D}${base_bindir}/zahif
}

FILES_${PN} += " \
    ${base_bindir}/hurracloud-agent \
    ${systemd_unitdir}/system/hurracloud-agent.service \
"
