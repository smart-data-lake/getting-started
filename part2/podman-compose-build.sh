#!/bin/bash

# This script executes the commands that podman-compose should have been able to execute.
# Unfortunately, due to the issue https://github.com/containers/podman-compose/issues/379#issuecomment-1000328181
# the different containers that are set up by the newer versions of podman-compose cannot communicate with each other,
# at least not without complicating the setup considerably, so we decided to not use podman-compose anymore.

# Run this script from the base directory of the repository, getting-started

podman build -v ~/.m2/repository:/mnt/.mvnrepo -f part2/metastore/Dockerfile -t localhost/part2_metastore

podman build -v ~/.m2/repository:/mnt/.mvnrepo -f part2/polynote/Dockerfile -t localhost/part2_polynote
