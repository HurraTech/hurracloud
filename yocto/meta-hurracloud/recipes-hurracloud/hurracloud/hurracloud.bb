SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "CLOSED"

SRC_URI += " \
    git://git@bitbucket.org/aimannajjar/deploy.git;protocol=ssh \
    file://hurracloud.service \
    file://hurra-update-images \
    file://docker-config.json \
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

do_compile() { 
    /usr/bin/gcloud kms decrypt --ciphertext-file=${WORKDIR}/git/gcr-creds.json.enc --plaintext-file=gcr-creds.json \
       --location=global \
       --keyring=cloudbuild \
       --key=cloudbuild
    cat gcr-creds.json | /usr/bin/docker login -u _json_key --password-stdin https://gcr.io

    mkdir -p ${WORKDIR}/images
	export ARCH=${HURRA_TARGETARCH}
    IMAGES=`/usr/local/bin/docker-compose -f ${WORKDIR}/git/docker-compose.yml config | grep 'image:' | awk '{print $2}' | xargs echo`
    for IMAGE in $IMAGES; do
        IMG_FILENAME=$(echo "$IMAGE" | awk -F/ '{print $NF}' | cut -d : -f1).tar.gz
        echo "Downloading image $IMAGE to ${WORKDIR}/images/$IMG_FILENAME";
        /usr/bin/docker pull $IMAGE
        /usr/bin/docker save $IMAGE | gzip > ${WORKDIR}/images/$IMG_FILENAME 
    done
}

do_install() {
    install -d ${D}${sysconfdir}/hurra ${D}${sysconfdir}/docker ${D}${base_libdir}/hurra ${D}${base_bindir} ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/git/docker-compose.yml ${D}${sysconfdir}/hurra/services.yml 
    install -m 0644 ${WORKDIR}/hurracloud.service ${D}${systemd_unitdir}/system
    install -m 0755 ${WORKDIR}/hurra-update-images ${D}${base_bindir}
    install -m 0644 ${WORKDIR}/images/*.gz ${D}${base_libdir}/hurra
    install -m 0644 ${WORKDIR}/docker-config.json ${D}${sysconfdir}/docker/daemon.json
}

# pkg_postinst_ontarget_${PN}() {
# #!/bin/sh -e
# until $(docker ps 1> /dev/null 2>&1); do echo "Waiting for Docker to start."; sleep 2; done
# ls $D${base_libdir}/hurra/*.gz | xargs -I{} sh -c 'gunzip -c {} | docker load'
# }

FILES_${PN} += " \
    ${sysconfdir}/hurra/services.yml \
    ${systemd_unitdir}/system/hurracloud.service \
    ${base_libdir}/hurra \
	${base_bindir}/hurra-update-images \
    ${sysconfdir}/docker/daemon.json \
"
