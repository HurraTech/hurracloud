#!/bin/bash
## ERROR_CODES:
# 1: Client name is already used
# 2: Faield to generate certificate, probably due to wrong CA password
# 3: Unknown error.  easyrsa reported successful exit, but ovpn_listclients is not listing the client name
## Expects CA_PASS environment variable
CLIENT_NAME=$1

if [ -f /etc/openvpn/pki/issued/${CLIENT_NAME}.crt ]; then
    echo "ERROR:1"
    exit -1
fi

easyrsa build-client-full $1 nopass >/dev/null 2>1
retval=$?
if [ $retval -ne 0 ]; then
    # Failed, clean up
    rm -f /etc/openvpn/pki/reqs/${CLIENT_NAME}.req
    rm -f /etc/openvpn/pki/private/${CLIENT_NAME}.key
    echo "ERROR:2"
    exit -1
fi

CLIENT_INFO=$(ovpn_listclients | grep "^${CLIENT_NAME},")
if [[ "${CLIENT_INFO}" == "" ]]; then
    echo "ERROR:3"
    rm -f /etc/openvpn/pki/private/${CLIENT_NAME}.key
    rm -f /etc/openvpn/pki/reqs/${CLIENT_NAME}.req
    rm -f /etc/openvpn/pki/issued${CLIENT_NAME}.crt
    exit -1
fi

echo "SUCCESS"