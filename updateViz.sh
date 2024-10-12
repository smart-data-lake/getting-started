#!/bin/bash

rm -rf viz/assets
rm -rf viz/images
rm viz/index.html

#latest snapshot
wget --no-check-certificate https://nightly.link/smart-data-lake/sdl-visualization/workflows/build/develop/sdl-visualizer.zip
#latest special snapshot
#wget --no-check-certificate https://nightly.link/smart-data-lake/sdl-visualization/actions/runs/8004975572/sdl-visualizer.zip
#latest release
#wget --no-check-certificate https://github.com/smart-data-lake/sdl-visualization/releases/latest/download/sdl-visualizer.zi

# save existing configuration
if [ -f viz/manifest.json ]; then
  mv viz/manifest.json viz/manifest.json.save
  mv viz/lighttpd.conf viz/lighttpd.conf.save
fi

unzip -uo sdl-visualizer.zip -d viz

rm sdl-visualizer.zip

# restore previous configuration
if [ -f viz/manifest.json.save ]; then
  mv viz/manifest.json viz/manifest.json.org
  mv viz/manifest.json.save viz/manifest.json
  mv viz/lighttpd.conf viz/lighttpd.conf.org
  mv viz/lighttpd.conf.save viz/lighttpd.conf
fi

# prepare index for state and config
chmod +x viz/build_index.sh

