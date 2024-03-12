#!/bin/bash

podman run -it --rm --name=spark-shell -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config --entrypoint="spark-shell" sdl-spark:latest $@
