#!/bin/bash

ovpn_genconfig -u udp://hurravpn
. /etc/openvpn/ovpn_env.sh && easyrsa init-pki
. /etc/openvpn/ovpn_env.sh && (yes AAAA | EASYRSA_BATCH=1 EASYRSA_REQ_CN=HurraVPN easyrsa build-ca)
. /etc/openvpn/ovpn_env.sh && easyrsa gen-dh
. /etc/openvpn/ovpn_env.sh && (yes AAAA | easyrsa build-server-full "$OVPN_CN" nopass -passin env:CA_PASS)

yes AAAA | easyrsa build-server-full "hurra2" nopass -passin env:CA_PASS