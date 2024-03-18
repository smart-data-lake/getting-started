#!/bin/bash

pushd viz

# make symlink to config
if [ ! -d ./config ]; then ln -s ../config; fi

# update state and config index
./build_index.sh ./state ./config

# start slim webserver as background process
ps -ef | grep lighttpd | grep -v grep | awk '{print $2}' | xargs -r kill
PORT=$(grep server.port lighttpd.conf | awk '{print $3}')
echo "Starting lighttpd serving SDLB UI on http://localhost:$PORT"
lighttpd -f lighttpd.conf
if [ $? -eq 0 ]; then echo "succeeded"; fi

popd