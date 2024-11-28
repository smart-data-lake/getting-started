#!/bin/bash

CONFIG_TARGET="${1:-file:/mnt/data/exportedConfig.json}"
SCHEMA_TARGET="${1:-file:/mnt/schema}"

# export configuration
export CLASS=io.smartdatalake.meta.configexporter.ConfigJsonExporter
./startJob.sh --config /mnt/config,/mnt/envConfig/dev.conf --target $CONFIG_TARGET

# export schema and statistics
export CLASS=io.smartdatalake.meta.configexporter.DataObjectSchemaExporter
./startJob.sh --config /mnt/config,/mnt/envConfig/dev.conf --target $SCHEMA_TARGET
