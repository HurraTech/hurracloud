SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "CLOSED"

require elasticsearch_${MACHINE}.inc

SRC_URI += " \
    https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.9.0-linux-${ES_TARGETARCH}.tar.gz \
    file://elasticsearch.service \
    file://systemd-entrypoint \
    file://elasticsearch.yml \
    file://log4j2.properties \
"

SRC_URI[sha256sum] = "d061434bc51ffadfbe4699314c0d1576a38021a609cd9be2f388ba60fe7d96f6"

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
    mkdir -p /data/es/logs
    chown -R elasticsearch:elasticsearch /data/es
    chown -R elasticsearch:elasticsearch /data/es/logs
}

do_install() {
    install -d ${D}/usr/share ${D}${systemd_unitdir}/system ${D}/var/log/elasticsearch
    cp -r ${S}/elasticsearch-7.9.0 ${D}/usr/share/elasticsearch 
	rm -rf ${D}/usr/share/elasticsearch/modules/x-pack-*
	rm -rf ${D}/usr/share/elasticsearch/modules/geo
    rm -rf ${D}/usr/share/elasticsearch/modules/aggs-matrix-stats
    rm -rf ${D}/usr/share/elasticsearch/modules/analysis-common
    rm -rf ${D}/usr/share/elasticsearch/modules/constant-keyword
    rm -rf ${D}/usr/share/elasticsearch/modules/flattened
    rm -rf ${D}/usr/share/elasticsearch/modules/frozen-indices
    rm -rf ${D}/usr/share/elasticsearch/modules/ingest-geoip
    rm -rf ${D}/usr/share/elasticsearch/modules/ingest-user-agent
    rm -rf ${D}/usr/share/elasticsearch/modules/kibana
    rm -rf ${D}/usr/share/elasticsearch/modules/mapper-extras
    rm -rf ${D}/usr/share/elasticsearch/modules/parent-join
    rm -rf ${D}/usr/share/elasticsearch/modules/percolator
    rm -rf ${D}/usr/share/elasticsearch/modules/repository-url
    rm -rf ${D}/usr/share/elasticsearch/modules/search-business-rules
    rm -rf ${D}/usr/share/elasticsearch/modules/searchable-snapshots
    rm -rf ${D}/usr/share/elasticsearch/modules/spatial
    rm -rf ${D}/usr/share/elasticsearch/modules/tasks
    rm -rf ${D}/usr/share/elasticsearch/modules/transform
    rm -rf ${D}/usr/share/elasticsearch/modules/wildcard
    rm -rf ${D}/usr/share/elasticsearch/modules/vectors 
    install -m 0644 ${WORKDIR}/elasticsearch.service ${D}${systemd_unitdir}/system
    install -m 0755 ${WORKDIR}/systemd-entrypoint ${D}/usr/share/elasticsearch/bin
    install -m 0644 ${WORKDIR}/elasticsearch.yml ${D}/usr/share/elasticsearch/config/elasticsearch.yml
    install -m 0644 ${WORKDIR}/log4j2.properties ${D}/usr/share/elasticsearch/config/log4j2.properties
    chown -R elasticsearch:elasticsearch ${D}/usr/share/elasticsearch
}

FILES_${PN} += " \
    /usr/share/elasticsearch \
    ${systemd_unitdir}/system \
"
