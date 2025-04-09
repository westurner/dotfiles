podman volume ls -qf dangling=true | el -v --each -x podman volume inspect | jq '.[0].Mountpoint' | sudo xargs du -hsc
