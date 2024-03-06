#!/bin/bash

# This script executes the commands that podman-compose should have been able to execute.
# Unfortunately, due to the issue https://github.com/containers/podman-compose/issues/379#issuecomment-1000328181
# the different containers that are set up by the newer versions of podman-compose cannot communicate with each other,
# at least not without complicating the setup considerably, so we decided to not use podman-compose anymore.

# Run this script from the base directory of the repository, getting-started

podman build -f part2/metastore/Dockerfile -t localhost/part2_metastore

podman build -v ${PWD}/.mvnrepo:/mnt/.mvnrepo -f part2/polynote/Dockerfile -t localhost/part2_polynote

# creating a network (default network is missing dns support)
podman create network getting-started

#metastore
echo "starting metatstore"
mkdir data/_metastore
podman run --rm -dt -p 1527:1527 --net getting-started --name=metastore -e DB_DIR=/mnt/database -v ${PWD}/data/_metastore:/mnt/database part2_metastore
echo .

#s3
#podman run --rm -dt -p 9000:9000 -p 9001:9001 --name=part2_s3 -v ${PWD}/data:/mnt/data quay.io/minio/minio server /mnt/data --console-address ":9001"
#podman run --rm -p 8333:8333 -p 8888:8888 --name=part2_s3 -v ${PWD}/data:/buckets docker.io/chrislusf/seaweedfs server -s3
podman run --rm -dt -p 8888:8888 --net getting-started --name=s3 -v ${PWD}/data:/mnt/data -e S3PROXY_ENDPOINT="http://0.0.0.0:8888" -e JCLOUDS_FILESYSTEM_BASEDIR="/mnt" -e S3PROXY_AUTHORIZATION=aws-v2-or-v4 -e S3PROXY_IDENTITY=admin -e S3PROXY_CREDENTIAL=1234 andrewgaul/s3proxy
echo .

#polynote
echo "starting polynote"
podman run --rm -p 8192:8192 -p "4140-4199:4140-4199" --net getting-started --name=polynote -v ${PWD}/part2/polynote/config.yml:/opt/polynote/config.yml -v ${PWD}/part2/polynote/notebooks:/mnt/notebooks -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config part2_polynote --config /opt/polynote/config.yml
