#!/bin/bash
set -e

CONF_DIR=/etc/openvpn/pki

mkdir -p ${CONF_DIR}/client_configs

CA_CRT=${CONF_DIR}/ca.crt
CONF=${CONF_DIR}/client_configs/$1.ovpn
KEY=${CONF_DIR}/private/$1.key
CRT=${CONF_DIR}/issued/$1.crt
TA=${CONF_DIR}/ta.key

cat >$CONF <<EOL
tls-client
remote hurracloud.duckdns.org
port 24407
dev tun
proto udp
route-gateway 10.9.0.1
float
route-method exe
route-delay 2
remote-cert-tls server
verb 3
topology subnet
ifconfig 10.9.0.5 255.255.255.0
cipher AES-256-CBC
key-direction 1
pull
EOL

printf "<tls-auth>\n" >> "$CONF"
cat $TA >> "$CONF"
printf "</tls-auth>\n" >> "$CONF"


printf "<ca>\n" >> "$CONF"
cat $CA_CRT >> "$CONF"
printf "</ca>\n" >> "$CONF"

printf "<cert>\n" >> "$CONF"
cat $CRT >> "$CONF"
printf "</cert>\n" >> "$CONF"

printf "<key>\n" >> "$CONF"
cat $KEY >> "$CONF"
printf "</key>\n" >> "$CONF"

cat $CONF