#!/bin/bash

# Optional overrides: $1 for the configuration export, $2 for the schema/statistics export.
# The configuration export writes a *single file*, so it needs the localfile: scheme. A bare
# path or a file: URI is a hadoop path, i.e. an output directory, and would leave the export at
# .../exportedConfig.json/exportedConfig.json instead. The schema export writes one document
# per DataObject, so a directory target is correct there.
CONFIG_TARGET="${1:-localfile:/mnt/data/exportedConfig.json}"
SCHEMA_TARGET="${2:-file:/mnt/schema}"

# export configuration
export CLASS=io.smartdatalake.meta.configexporter.ConfigJsonExporter
./startJob.sh --config /mnt/config,/mnt/envConfig/dev.conf --target $CONFIG_TARGET

# export schema and statistics
export CLASS=io.smartdatalake.meta.configexporter.DataObjectSchemaExporter
./startJob.sh --config /mnt/config,/mnt/envConfig/dev.conf --target $SCHEMA_TARGET
