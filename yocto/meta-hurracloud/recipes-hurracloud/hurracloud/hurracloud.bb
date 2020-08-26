SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "CLOSED"

SRC_URI += " \
    git://git@bitbucket.org/aimannajjar/deploy.git;protocol=ssh \
    file://hurracloud.service \
    file://hurra-start \
    file://hurra-stop \
"

SRCREV = "${AUTOREV}"

PV = "1.0"

inherit systemd
require hurracloud_${MACHINE}.inc

RPROVIDES_${PN} = "hurracloud"
RDEPENDS_${PN} = "docker-ce"

S = "${WORKDIR}"

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_${PN} = "hurracloud.service"

INSANE_SKIP_${PN} = "ldflags"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"


do_compile() { 
    # Reset local docker and pull latest images to it
    sudo systemctl stop docker && sudo rm -rf /var/lib/docker && install -d ${D}{localstatedir}/lib/docker && sudo systemctl start docker
    until $(/usr/bin/docker ps 1> /dev/null 2>&1); do echo "Waiting for Docker to start."; sleep 2; done
	
    export ARCH=${HURRA_TARGETARCH}
    IMAGES=`/usr/local/bin/docker-compose -f ${WORKDIR}/git/docker-compose.yml config | grep 'image:' | awk '{print $2}' | xargs echo`
    for IMAGE in $IMAGES; do
        IMG_FILENAME=$(echo "$IMAGE" | awk -F/ '{print $NF}' | cut -d : -f1)
        echo "Downloading image $IMAGE to ${WORKDIR}/images/$IMG_FILENAME";
        /usr/bin/docker pull --platform=$ARCH $IMAGE
    done
    sudo systemctl stop docker
}

do_install() {
    install -d ${D}${base_bindir} ${D}${systemd_unitdir}/system install ${D}${localstatedir}/lib
    install -m 0644 ${WORKDIR}/git/docker-compose.yml ${D}/services.yml 
    install -m 0644 ${WORKDIR}/hurracloud.service ${D}${systemd_unitdir}/system
    install -m 0755 ${WORKDIR}/hurra-start ${D}${base_bindir}
    install -m 0755 ${WORKDIR}/hurra-stop ${D}${base_bindir}
    sudo tar -cf ${D}${localstatedir}/lib/docker.tar -C /var/lib/ docker
}

pkg_postinst_${PN}() {
#!/bin/sh -e
cd $D${localstatedir}/lib && tar -xf docker.tar && rm docker.tar
}

FILES_${PN} += " \
    /services.yml \
    ${systemd_unitdir}/system/hurracloud.service \
    ${base_bindir} \
    ${localstatedir}/docker.tar \
"
