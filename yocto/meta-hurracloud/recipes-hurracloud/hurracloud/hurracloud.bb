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
RDEPENDS_${PN} = "docker-ce redis elasticsearch ruby"

S = "${WORKDIR}"

SYSTEMD_AUTO_ENABLE_${PN} = "enable"
SYSTEMD_SERVICE_${PN} = "hurracloud.service"

INSANE_SKIP_${PN} = "ldflags staticdev file-rdeps"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"


IMAGES = "jawhar=gcr.io/hurrabuild/jawhar:latest samaa=gcr.io/hurrabuild/samaa:latest"
IMAGE_ARTIFACTS_jawhar = "/usr/local/bundle/.:/opt/hurracloud/gems /app/.:/opt/hurracloud/jawhar"
IMAGE_ARTIFACTS_samaa = "/home/node/samaa/.:/opt/hurracloud/samaa"

python do_compile() {
    import subprocess

    subprocess.call("/usr/bin/docker rmi $(/usr/bin/docker images -qa)", shell=True)

    for image in d.getVar('IMAGES').split(" "):
        (image_name, image_url) = image.split("=")
        image_artifacts = d.getVar("IMAGE_ARTIFACTS_%s" % image_name) 
        subprocess.call("/usr/bin/docker pull --platform=%s %s" % (d.getVar('HURRA_TARGETARCH'), image_url), shell=True)

        subprocess.call("/usr/bin/docker create --name %s %s" % (image_name, image_url), shell=True)
        for artifact in image_artifacts.split(" "):
            (src, dst) = artifact.split(":")
            dst = "%s%s" % (d.getVar('WORKDIR'), dst)
            print("Copying artifact %s to %s" % (src,dst))
            subprocess.call("mkdir -p %s" % dst, shell=True)    
            subprocess.call("/usr/bin/docker cp %s:%s %s" % (image_name, src, dst), shell=True)

        subprocess.call("/usr/bin/docker rm %s" % image_name, shell=True)
}

do_install() {
    install -d ${D}${base_bindir} ${D}${systemd_unitdir}/system install ${D}${localstatedir}/lib ${D}${sysconfdir}/avahi ${D}/opt
    install -m 0644 ${WORKDIR}/hurracloud.service ${D}${systemd_unitdir}/system
    install -m 0755 ${WORKDIR}/hurra-start ${D}${base_bindir}
    install -m 0755 ${WORKDIR}/hurra-stop ${D}${base_bindir}
    cp -R ${WORKDIR}/opt/hurracloud ${D}/opt/hurracloud
}

pkg_postinst_ontarget_${PN} () {
    mkdir -p /data/redis
    chown -R redis:redis /data/redis
}


FILES_${PN} += " \
    /services.yml \
    ${systemd_unitdir}/system/hurracloud.service \
    ${base_bindir} \
    ${localstatedir}/docker.tar \
    /opt/hurracloud \
"
