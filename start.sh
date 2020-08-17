#!/bin/bash
export HOSTNAME=$(hostname)
MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64'  ]; then
    ARCH="amd64"
else
    ARCH="arm64"
fi

export ARCH;

docker-compose -f docker-compose.yml up -d
