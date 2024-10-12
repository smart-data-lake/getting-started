#!/bin/bash

set -f # disable star expansion
podman run --rm --name=sdlb-job -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config -v ${PWD}/envConfig:/mnt/envConfig -v ${PWD}/viz/state:/mnt/state -v ${PWD}/viz/description:/mnt/description -v ${PWD}/viz/schema:/mnt/schema -e CLASS=$CLASS sdl-spark:latest $@
