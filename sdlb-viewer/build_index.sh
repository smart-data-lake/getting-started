#!/usr/bin/env bash

# PYTHON INDEX BUILDER
set -e
python3 -m venv .venv
source "./.venv/bin/activate"
pip install -r ./requirements.txt
python3 ./build_index.py state config
deactivate