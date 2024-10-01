#!/bin/bash

# make sure user maven repository exists
mkdir -p ~/.m2/repository

# cleanup generated catalog files
rm -rf src/main/scala-generated

# start maven build
podman run -v ${PWD}:/mnt/project -v ~/.m2/repository:/mnt/.mvnrepo -w /mnt/project  maven:3-eclipse-temurin-17  mvn -f /mnt/project/pom.xml "-Dmaven.repo.local=/mnt/.mvnrepo" package -Pgenerate-catalog
