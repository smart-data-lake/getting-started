#!/bin/bash
if ! command -v lighttpd &> /dev/null
then
  sudo apt install lighttpd
fi
# Delete configuration files in the viewer folder
rm -r "$PWD/sdlb-viewer/config"

rm -r "$PWD/sdlb-viewer/state"

# Copy the contents of the 'config' directory to 'sdlb-viewer/config'
cp -r "$PWD/config" "$PWD/sdlb-viewer/config"

# Copy the contents of the 'state' directory to 'sdlb-viewer/state'
cp -r "$PWD/data/state" "$PWD/sdlb-viewer/state"

# Copy the file 'sdlbViewer.conf' to 'sdlb-viewer/config'
cp "$PWD/envConfig/sdlbViewer.conf" "$PWD/sdlb-viewer/config"

# Change the working directory to 'sdlb-viewer'
cd "$PWD/sdlb-viewer"

# PYTHON INDEX BUILDER (switch to Python3 if needed)
set -e
pip install -r "./requirements.txt"
python3 "./build_index.py" state

lighttpd -D -f lighttpd.conf