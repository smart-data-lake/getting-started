#!/bin/bash

# export configuration
export CLASS=io.smartdatalake.meta.configexporter.ConfigJsonExporter
./startJob.sh --config /mnt/config,/mnt/envConfig/dev.conf --target file:/mnt/data/exportedConfig.json

# export schema and statistics
export CLASS=io.smartdatalake.meta.configexporter.DataObjectSchemaExporter
./startJob.sh --config /mnt/config,/mnt/envConfig/dev.conf --target file:/mnt/schema
