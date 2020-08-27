#!/bin/bash
## Expects CA_PASS environment variable

set -e

IP=$(route -n | grep 'UG[ \t]' | grep -v 'tun0' | awk '{print $2}')
NETMASK=$(ifconfig | grep -B1 -A2 $IP | sed -rn '2s/ .*:(.*)$/\1/p')
IFS=. read -r i1 i2 i3 i4 <<< $IP
IFS=. read -r m1 m2 m3 m4 <<< $NETMASK
NETWORK=$(printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))")

ovpn_genconfig -u udp://hurravpn -e "topology subnet" -e "mode server" -e "tls-server" -p "route ${NETWORK} ${NETMASK}"
