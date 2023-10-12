#!/bin/bash

# Delete configuration files in the viewer folder
rm -r "$PWD/sdlb-viewer/config"

# Copy the contents of the 'config' directory to 'sdlb-viewer/config'
cp -r "$PWD/config" "$PWD/sdlb-viewer/config"

# Copy the file 'sdlbViewer.conf' to 'sdlb-viewer/config'
cp "$PWD/envConfig/sdlbViewer.conf" "$PWD/sdlb-viewer/config"

# Change the working directory to 'sdlb-viewer'
cd "$PWD/sdlb-viewer"

# PYTHON INDEX BUILDER (switch to Python3 if needed)
set -e
python3 -m venv .venv
source "./.venv/bin/activate"
pip install -r "./requirements.txt"
python3 "./build_index.py" state
deactivate

lighttpd -D -f lighttpd.conf