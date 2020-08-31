SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "CLOSED"

SRC_URI += " \
    git://git@bitbucket.org/aimannajjar/hurra-agent.git;protocol=ssh \
    file://hurra-agent.service \
"

SRCREV = "${AUTOREV}"

PV = "1.0"

inherit go systemd

RPROVIDES_${PN} = "hurra-agent"

S = "${WORKDIR}/git"

SYSTEMD_AUTO_ENABLE_${PN} = "enable"
SYSTEMD_SERVICE_${PN} = "hurra-agent.service"

GO_IMPORT = "hurra-agent"

do_compile() {
  export GOPATH=$S
  go get github.com/golang/protobuf/proto
  go get google.golang.org/grpc
  cd ${S}/src/hurra-agent && go build ./server.go 
}

do_install() {
    install -d ${D}${base_bindir} ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/hurra-agent.service ${D}${systemd_unitdir}/system
    install -m 0755 ${S}/src/hurra-agent/server ${D}${base_bindir}/hurra-agent
}

FILES_${PN} += " \
    ${base_bindir}/hurra-agent \
    ${systemd_unitdir}/system/hurra-agent.service \
"
