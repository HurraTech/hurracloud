require sqlite3.inc

LICENSE = "PD"
LIC_FILES_CHKSUM = "file://sqlite3.h;endline=11;md5=786d3dc581eff03f4fd9e4a77ed00c66"

SRC_URI = "http://www.sqlite.org/2019/sqlite-autoconf-${SQLITE_PV}.tar.gz \
           file://0001-Fix-CVE-2019-16168.patch \
           file://CVE-2019-19244.patch \
           file://CVE-2019-19923.patch \
           file://CVE-2019-19924.patch \
           file://CVE-2019-19925.patch \
           file://CVE-2019-19926.patch \
           file://CVE-2019-19959.patch \
           file://CVE-2019-20218.patch \
           file://CVE-2020-11655.patch \
"
SRC_URI[md5sum] = "8f3dfe83387e62ecb91c7c5c09c688dc"
SRC_URI[sha256sum] = "8e7c1e2950b5b04c5944a981cb31fffbf9d2ddda939d536838ebc854481afd5b"
