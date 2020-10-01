FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append = "file://docker.service"

do_install_append() {
	install -m 644 ${WORKDIR}/docker.service ${D}/${systemd_unitdir}/system
}
