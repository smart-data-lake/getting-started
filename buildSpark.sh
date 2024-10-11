#!/bin/bash

# make sure user maven repository exists
mkdir -p ~/.m2/repository

# start maven build
# seccomp=unconfined is needed for current ubuntu 22.04, otherwise there "untar" has problems setting permissions for directories, see also https://bugs.launchpad.net/ubuntu/+source/tar/+bug/2059734 and https://github.com/ocaml/infrastructure/issues/121
podman build --security-opt seccomp=unconfined -v ~/.m2/repository:/mnt/.mvnrepo -t sdl-spark -f spark/Dockerfile .
buildSpark.sh
