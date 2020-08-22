SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "CLOSED"

SRC_URI += " \
    git://git@bitbucket.org/aimannajjar/deploy.git;protocol=ssh \
"

SRCREV = "${AUTOREV}"

PV = "1.0"

inherit package update-rc.d
require hurracloud_${MACHINE}.inc

RDEPENDS_${PN} = "initscripts"
RPROVIDES_${PN} = "hurracloud"

S = "${WORKDIR}"

INITSCRIPT_PACKGES = "${PN}"
INITSCRIPT_NAME = "start-hurracloud"
INITSCRIPT_PARAMS = "start 99 2 3 4 5 ."

do_compile() { 
    /usr/bin/gcloud kms decrypt --ciphertext-file=${WORKDIR}/git/gcr-creds.json.enc --plaintext-file=gcr-creds.json \
       --location=global \
       --keyring=cloudbuild \
       --key=cloudbuild
    cat gcr-creds.json | /usr/bin/docker login -u _json_key --password-stdin https://gcr.io

    echo "RUNNING ${HURRA_TARGETARCH} /usr/local/bin/docker-compose -f ${WORKDIR}/git/docker-compose.yml config | grep 'image:' | awk '{print $2}'"
    mkdir -p ${WORKDIR}/images
	export ARCH=${HURRA_TARGETARCH}
    IMAGES=`/usr/local/bin/docker-compose -f ${WORKDIR}/git/docker-compose.yml config | grep 'image:' | awk '{print $2}' | xargs echo`
    echo "IMAGES ARE $IMAGES"
    for IMAGE in $IMAGES; do
        IMG_FILENAME=$(echo "$IMAGE" | awk -F/ '{print $NF}' | cut -d : -f1).tar
        echo "Downloading image $IMAGE to $IMG_FILENAME";
        /usr/bin/docker pull $IMAGE
        /usr/bin/docker save -o $IMG_FILENAME $IMAGE
    done
#        xargs -I{} sh -c 'echo "Downloading $1" && /usr/bin/docker save -o ./$(date +%s).tar $1' sh {}
}

do_install() {
    install -d ${D}${sysconfdir}/ {D}${sysconfdir}/hurra ${D}${base_libdir}/hurra/
    install -m 0644 ${WORKDIR}/git/docker-compose.yml ${D}${sysconfdir}/hurra/services.yml 
    install -m 0644 ${WORKDIR}/images/*.tar ${D}${base_libdir}/hurra/
}

FILES_${PN} += " \
    ${sysconfdir} \
    ${sysconfdir}/init.d/start-hurracloud \
"
