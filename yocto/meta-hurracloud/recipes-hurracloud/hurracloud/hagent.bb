SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "CLOSED"

SRC_URI += " \
    git://git@bitbucket.org/aimannajjar/hagent.git;protocol=ssh \
    file://hagent.service \
"

SRCREV = "${AUTOREV}"

PV = "1.0"

inherit go systemd

RPROVIDES_${PN} = "hagent"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

SYSTEMD_AUTO_ENABLE_${PN} = "enable"
SYSTEMD_SERVICE_${PN} = "hagent.service"

GO_IMPORT = "hagent"

do_compile() {
  sudo rm -rf ${B}/pkg # thanks to go weird cache permissions 
  cd ${S}/src/hagent && go build ./server.go
}

do_install() {
    install -d ${D}${base_bindir} ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/hagent.service ${D}${systemd_unitdir}/system
    install -m 0755 ${S}/src/hagent/server ${D}${base_bindir}/hagent
}

FILES_${PN} += " \
    ${base_bindir}/hagent \
    ${systemd_unitdir}/system/hagent.service \
"
