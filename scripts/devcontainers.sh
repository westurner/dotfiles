#!/bin/sh
set -x

podman image ls -f 'label=devcontainer.metadata*'

#podman ps -f 'label=devcontainer.metadata*'
#podman ps -a -f 'label=devcontainer.metadata*'
#podman ps -a -f 'label=devcontainer.metadata*' --format "{{json .}}" | jq '.Labels."devcontainer.metadata" | fromjson'
#podman ps -f 'label=devcontainer.metadata*' --format "{{json .}}" | jq '.Labels."devcontainer.metadata" | fromjson'
podman ps -a -f 'label=devcontainer.metadata*' --format "{{json .}}" | jq '{Id, Image, devmetadata: .Labels."devcontainer.metadata"| fromjson}'

