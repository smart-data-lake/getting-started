#!/bin/bash

export CLASS=io.smartdatalake.meta.configexporter.DataObjectSchemaExporter

./startJob.sh --config /mnt/config,/mnt/envConfig/dev.conf --exportPath /mnt/schema
