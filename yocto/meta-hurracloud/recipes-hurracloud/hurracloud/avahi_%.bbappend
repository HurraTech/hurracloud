FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append = " file://avahi-daemon.conf"
do_install_append() {
    install ${WORKDIR}/avahi-daemon.conf ${D}${sysconfdir}/avahi/avahi-daemon.conf
}

