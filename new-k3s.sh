#!/bin/bash

k3d create -a 172.16.0.99:6443 \
        --volume ${HOME}/.k3d/config.toml.tmpl:/var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl\
        --volume /usr/share/hurracloud/mounts:/usr/share/hurracloud/mounts\
        --volume /usr/share/hurracloud/jawhar/data:/usr/share/hurracloud/jawhar/data\
        --volume /dev/bus/usb:/dev/bus/usb \
        --publish 80:80

