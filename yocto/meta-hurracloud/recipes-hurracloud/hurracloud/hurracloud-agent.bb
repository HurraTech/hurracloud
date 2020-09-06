SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "CLOSED"

SRC_URI += " \
    git://git@bitbucket.org/aimannajjar/hurracloud-agent.git;protocol=ssh \
    file://hurracloud-agent.service \
"

SRCREV = "${AUTOREV}"

PV = "1.0"

inherit go systemd

RPROVIDES_${PN} = "hurracloud-agent"

S = "${WORKDIR}/git"

SYSTEMD_AUTO_ENABLE_${PN} = "enable"
SYSTEMD_SERVICE_${PN} = "hurracloud-agent.service"

GO_IMPORT = "hurracloud-agent"

do_compile() {
  export GOPATH=$S
  go get github.com/golang/protobuf/proto
  go get google.golang.org/grpc
  cd ${S}/src/hurracloud-agent && go build ./server.go 
}

do_install() {
    install -d ${D}${base_bindir} ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/hurracloud-agent.service ${D}${systemd_unitdir}/system
    install -m 0755 ${S}/src/hurracloud-agent/server ${D}${base_bindir}/hurracloud-agent
}

FILES_${PN} += " \
    ${base_bindir}/hurracloud-agent \
    ${systemd_unitdir}/system/hurracloud-agent.service \
"
