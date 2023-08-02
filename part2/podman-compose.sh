#!/bin/bash

#This script executes the commands that podman-compose should have been able to execute.
# Unfortunately, due to the issue https://github.com/containers/podman-compose/issues/379#issuecomment-1000328181
# the different containers that are set up by the newer versions of podman-compose cannot communicate with each other,
# at least not without complicating the setup considerably, so we decided to not use podman-compose anymore.

#Run this script from the base directory of the repository, getting-started

podman build -f part2/metastore/Dockerfile -t localhost/part2_metastore

podman build -f part2/polynote/Dockerfile -t localhost/part2_polynote

podman stop --all
podman pod rm -i getting-started

podman pod create --name getting-started -p 8192:8192 -p 4140-4199:4140-4199 -p 1080:1080

#metastore
podman run -dt --pod getting-started --name=part2_metastore --label com.docker.compose.service=metastore -e DB_DIR=/mnt/database -v ${PWD}/data/_metastore:/mnt/database part2_metastore

#polynote
podman run  --pod getting-started --name=part2_polynote --requires=part2_metastore --label com.docker.compose.service=polynote -v ${PWD}/part2/polynote/config.yml:/opt/polynote/config.yml -v ${PWD}/part2/polynote/notebooks:/mnt/notebooks -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config part2_polynote --config /opt/polynote/config.yml
