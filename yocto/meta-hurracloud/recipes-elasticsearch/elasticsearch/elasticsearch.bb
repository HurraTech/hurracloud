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

S = "${WORKDIR}"

# SYSTEMD_AUTO_ENABLE_${PN} = "enable"
# SYSTEMD_SERVICE_${PN} = "hurracloud.service"
PRIVATE_LIBS_${PN} = "\
    libstdc++.so \
    libgcc_s.so \
"
do_install() {
    install -d ${D}/usr/share/elasticsearch
    cp -r ${S}/elasticsearch-7.9.0 /usr/share/elasticsearch
    install serviceFile ymlCOnfigFile systemdEntrypoint
}

FILES_${PN} += " \
    /opt/elasticsearch \
"
