#!/bin/bash
set -e

pushd viz

# make symlink to config
if [ ! -d ./config ]; then ln -s ../config; fi
if [ ! -d ./envConfig ]; then ln -s ../envConfig; fi

# update state and config index
./build_index.sh ./state ./config

# start slim webserver
ps -ef | grep lighttpd | grep -v grep | awk '{print $2}' | xargs -r kill
PORT=$(grep server.port lighttpd.conf | awk '{print $3}')
echo
echo "Starting lighttpd serving SDLB UI on http://localhost:$PORT"
lighttpd -D -f lighttpd.conf

popd
