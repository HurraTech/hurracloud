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
        /usr/bin/docker pull $IMAGE
    done
    sudo systemctl stop docker
}

do_install() {
    install -d ${D}${base_bindir} ${D}${sysconfdir}/hurra ${D}${sysconfdir}/docker ${D}${systemd_unitdir}/system install ${D}${localstatedir}/lib
    install -m 0644 ${WORKDIR}/git/docker-compose.yml ${D}${sysconfdir}/hurra/services.yml 
    install -m 0644 ${WORKDIR}/hurracloud.service ${D}${systemd_unitdir}/system
    install -m 0755 ${WORKDIR}/hurra-start ${D}${base_bindir}
    install -m 0755 ${WORKDIR}/hurra-stop ${D}${base_bindir}
    
    # Download docker images (host's docker daemon must use ${D}${localstatedir}/lib/docker as data path)
    /usr/bin/gcloud kms decrypt --ciphertext-file=${WORKDIR}/git/gcr-creds.json.enc --plaintext-file=gcr-creds.json \
       --location=global \
       --keyring=cloudbuild \
       --key=cloudbuild
    cat gcr-creds.json | /usr/bin/docker login -u _json_key --password-stdin https://gcr.io

    # Package local docker 
    sudo tar -cf ${D}${localstatedir}/lib/docker.tar -C /var/lib/ docker
}

pkg_postinst_${PN}() {
#!/bin/sh -e
cd $D${localstatedir}/lib && tar -xf docker.tar && rm docker.tar
}

FILES_${PN} += " \
    ${sysconfdir}/hurra/services.yml \
    ${systemd_unitdir}/system/hurracloud.service \
    ${base_bindir} \
    ${localstatedir}/docker.tar \
"
