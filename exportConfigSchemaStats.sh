#!/bin/bash

# Optional overrides: $1 for the configuration export, $2 for the schema/lineage/statistics export.
# The configuration export writes a *single file*, so it needs the localfile: scheme. A bare
# path or a file: URI is a hadoop path, i.e. an output directory, and would leave the export at
# .../exportedConfig.json/exportedConfig.json instead. The schema/lineage export writes documents
# per DataObject, so a directory target is correct there.
CONFIG_TARGET="${1:-localfile:/mnt/data/exportedConfig.json}"
SCHEMA_TARGET="${2:-localfile:/mnt/schema}"

# export configuration
export CLASS=io.smartdatalake.meta.configexporter.ConfigJsonExporter
./startJob.sh --config /mnt/config,/mnt/envConfig/dev.conf --target $CONFIG_TARGET

# export schema and column lineage of the output DataObjects with a dry-run.
# Remove the previous export first: global.dataObjectsSchemaSource is also where the dry-run reads
# input schemas from, so stale documents would otherwise be exported again unchanged.
# This only applies to the default target, which is the viz/schema mount.
if [ -z "$2" ]; then rm -f viz/schema/*.json viz/schema/*.txt; fi
export CLASS=io.smartdatalake.app.DefaultSmartDataLakeBuilder
SDLB_SCHEMA_SOURCE=$SCHEMA_TARGET SDLB_DESCRIPTION_PATH=/mnt/description \
  ./startJob.sh --config /mnt/config,/mnt/envConfig/dev.conf --feed-sel '.*' -n getting-started --test dry-run-with-lineage-export

# export statistics, which the dry-run does not export. Schemas are left to the dry-run.
export CLASS=io.smartdatalake.meta.configexporter.DataObjectSchemaExporter
./startJob.sh --config /mnt/config,/mnt/envConfig/dev.conf --target $SCHEMA_TARGET --withSchema false
