SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "CLOSED"

require elasticsearch_${MACHINE}.inc

SRC_URI += " \
    https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.9.0-linux-${ES_TARGETARCH}.tar.gz \
    file://elasticsearch.service \
    file://systemd-entrypoint \
    file://elasticsearch.yml \
"

SRC_URI[sha256sum] = "fe2a1b4714e553e198e03047c974b06a356f1948d69edde9bc0a4c277399737e"

SRCREV = "${AUTOREV}"

PV = "1.0"

inherit systemd useradd

USERADD_PACKAGES = "${PN}"
RPROVIDES_${PN} = "elasticsearch"
RDEPENDS_${PN} = "zlib bash"
USERADD_PARAM_${PN} = "-u 1200 -r elasticsearch"
S = "${WORKDIR}"

SYSTEMD_AUTO_ENABLE_${PN} = "enable"
SYSTEMD_SERVICE_${PN} = "elasticsearch.service"
INSANE_SKIP_${PN} = "ldflags libdir"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"

PRIVATE_LIBS_${PN} = "\
    libstdc++.so.6 \
    libgcc_s.so.1 \
"

pkg_postinst_ontarget_${PN} () {
    mkdir -p /data/es
    chown elasticsearch:elasticsearch /data/es
}

do_install() {
    install -d ${D}/usr/share ${D}${systemd_unitdir}/system ${D}/var/log/elasticsearch
    cp -r ${S}/elasticsearch-7.9.0 ${D}/usr/share/elasticsearch 
    install -m 0644 ${WORKDIR}/elasticsearch.service ${D}${systemd_unitdir}/system
    install -m 0755 ${WORKDIR}/systemd-entrypoint ${D}/usr/share/elasticsearch/bin
    install -m 0644 ${WORKDIR}/elasticsearch.yml ${D}/usr/share/elasticsearch/config/elasticsearch.yml
    chown -R elasticsearch ${D}/usr/share/elasticsearch
    chown -R elasticsearch ${D}/var/log/elasticsearch
}

FILES_${PN} += " \
    /usr/share/elasticsearch \
    ${systemd_unitdir}/system \
"
