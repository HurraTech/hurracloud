#!/bin/bash
# Requirements
# 1. https://github.com/astrada/google-drive-ocamlfuse (see https://github.com/astrada/google-drive-ocamlfuse/issues/571#issuecomment-533380311)
# 2. ntfs-3d
mkdir -p mounts/internal-1
mkdir -p data

export MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64'  ]; then
    ARCH="amd64"
else
    ARCH="arm64"
fi


HURRA_HOSTNAME=$(hostname -A | cut -d " " -f 1) ARCH=$ARCH docker-compose -f docker-compose.yml pull
HURRA_HOSTNAME=$(hostname -A | cut -d " " -f 1) ARCH=$ARCH docker-compose -f docker-compose.yml up -d
