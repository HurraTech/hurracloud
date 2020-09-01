FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append = " file://redis.conf"

SYSTEMD_AUTO_ENABLE_${PN} = "enable"
