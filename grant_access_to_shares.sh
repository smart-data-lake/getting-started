#!/bin/bash

podman unshare chown 1000:1000 -R polynote/notebooks  # grant write access to polly
podman unshare chown 1000:1000 -R data  # grant write access to polly

