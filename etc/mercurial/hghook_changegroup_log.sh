#!/bin/sh
# HG_SOURCE # serve | pull | push | bundle

if [ "$HG_SOURCE" == "pull" ]; then
    # HG_URL # 'remote:ssh:url' | 'remote:http:url' | <>
    export

    echo $(date) # TODO
    echo $HG_NODE
    echo $HG_SOURCE
    echo $HG_URL
fi
