#!/bin/bash

# make sure user maven repository exists
mkdir -p ~/.m2/repository

# start maven build
podman run -v ${PWD}:/mnt/project -v ~/.m2/repository:/mnt/.mvnrepo maven:3.9.6-eclipse-temurin-17 mvn -f /mnt/project/pom.xml "-Dmaven.repo.local=/mnt/.mvnrepo" package