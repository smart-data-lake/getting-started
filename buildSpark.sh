#!/bin/bash

# make sure user maven repository exists
mkdir -p ~/.m2/repository

# start maven build
podman build -v ~/.m2/repository:/mnt/.mvnrepo -t sdl-spark -f spark/Dockerfile ..
