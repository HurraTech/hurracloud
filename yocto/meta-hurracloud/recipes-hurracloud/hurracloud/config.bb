SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "CLOSED"

SRC_URI += " \
    file://wpa_supplicant.conf \
    file://resolv.conf \
    file://start-hurracloud \
"

PV = "1.0"

inherit update-rc.d

RDEPENDS_${PN} = "initscripts"
RPROVIDES_${PN} = "hurracloud"

S = "${WORKDIR}"

INITSCRIPT_PACKGES = "${PN}"
INITSCRIPT_NAME = "start-hurracloud"
INITSCRIPT_PARAMS = "start 99 2 3 4 5 ."

do_install() {
    install -d ${D}${sysconfdir}/
    install -d ${D}${sysconfdir}/init.d
    install -m 0644 ${WORKDIR}/wpa_supplicant.conf ${D}${sysconfdir}/
    install -m 0644 ${WORKDIR}/resolv.conf ${D}${sysconfdir}/
    install -m 0755 ${WORKDIR}/start-hurracloud ${D}${sysconfdir}/init.d/
}

FILES_${PN} += " \
    ${sysconfdir} \
    ${sysconfdir}/init.d/start-hurracloud \
"
