#!/bin/bash

k3d create -a 172.16.0.99:6443 --volume ${HOME}/.k3d/config.toml.tmpl:/var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl --volume /usr/share/hurracloud/mounts:/usr/share/hurracloud/mounts --publish 80:80 --publish 1024-10000:80
