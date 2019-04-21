#!/bin/bash
if [$CA_PASS == ""]; then
    echo "ERROR";
    exit -1;
fi

(yes yes | ovpn_revokeclient $1 >/dev/null 2>1 && echo 'SUCCESS') || echo 'ERROR';