SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "CLOSED"

SRC_URI += " \
    git://git@bitbucket.org/aimannajjar/deploy.git;protocol=ssh \
    http://deb.debian.org/debian/pool/main/libf/libffi/libffi6_3.2.1-9_${HURRA_TARGETARCH}.deb;name=libffi6 \
    http://deb.debian.org/debian/pool/main/f/file/libmagic1_5.35-4+deb10u1_${HURRA_TARGETARCH}.deb;name=libmagic1 \
    http://deb.debian.org/debian/pool/main/s/sqlite3/libsqlite3-0_3.27.2-3_${HURRA_TARGETARCH}.deb;name=libsqlite3-0 \
    file://hurracloud.service \
    file://hurra-start \
    file://hurra-stop \
"

SRCREV = "${AUTOREV}"
SRC_URI[libffi6.sha256sum] = "c5f7f4158dc6821bf37dd44ce0fe4399b5798d4ae7e821ad85b63059a2b31c0f"
SRC_URI[libmagic1.sha256sum] = "25a5001e173bfed25cfa95d9a03c0d3bc2eeae68f1fad49eb17a0ce12c1cd3fb"
SRC_URI[libsqlite3-0.sha256sum] = "dc640195d3a2958f04f78b3bc8835ea0ca0105c12c179571555616b3b4e4a59f"
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

ARCH_DIR_x86-64 = "x86-64-linux-gnu"
ARCH_DIR_aarch64 = "aarch64-linux-gnu"

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

    # install required libraries
    install -m 0755 -d ${D}${libdir}
    install -d ${D}${includedir}
    oe_soinstall ${S}/usr/lib/${ARCH_DIR}/libffi.so.6.0.4 ${D}${libdir}
    oe_soinstall ${S}/usr/lib/${ARCH_DIR}/libmagic.so.1.0.0 ${D}${libdir}
    oe_soinstall ${S}/usr/lib/${ARCH_DIR}/libsqlite3.so.0.8.6 ${D}${libdir}
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
    ${libdir} \
"
