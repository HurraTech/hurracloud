SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "CLOSED"

require elasticsearch_${MACHINE}.inc

SRC_URI += " \
    https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.9.0-linux-${ES_TARGETARCH}.tar.gz \
"

SRC_URI[sha256sum] = "fe2a1b4714e553e198e03047c974b06a356f1948d69edde9bc0a4c277399737e"

SRCREV = "${AUTOREV}"

PV = "1.0"

inherit systemd

RPROVIDES_${PN} = "elasticsearch"
INSANE_SKIP_${PN} = "ldflags"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"

S = "${WORKDIR}"

# SYSTEMD_AUTO_ENABLE_${PN} = "enable"
# SYSTEMD_SERVICE_${PN} = "hurracloud.service"

do_install() {
    install -d ${D}/opt
    mv ${S}/elasticsearch-7.9.0 ${D}/opt/elasticsearch
    chown -Rv 1000:1000 ${D}/opt/elasticsearch 
}


FILES_${PN} += " \
    /opt/elasticsearch \
"
