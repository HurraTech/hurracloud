#!/bin/bash
(yes yes | ovpn_revokeclient $1 >/dev/null 2>1 && echo 'SUCCESS') || echo 'ERROR'