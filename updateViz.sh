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
  mv viz/manifest.json viz/manifest.json.save;
  mv viz/lighttpd.json viz/lighttpd.json.save;
fi

unzip -uo sdl-visualizer.zip -d viz

rm sdl-visualizer.zip

# save previous configuration
if [ -f viz/manifest.json.save ]; then
  mv viz/manifest.json viz/manifest.json.org
  mv viz/manifest.json.save viz/manifest.json
  mv viz/lighttpd.json viz/lighttpd.json.org
  mv viz/lighttpd.json.save viz/lighttpd.json
fi

# prepare index for state and config
chmod +x viz/build_index.sh