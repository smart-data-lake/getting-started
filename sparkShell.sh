#!/bin/bash


set -f # disable star expansion
podman run -it --rm --name=spark-shell -p "4040-4099:4040-4099" -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config -v ${PWD}/envConfig:/mnt/envConfig -v ${PWD}/shell.scala:/mnt/shell.scala -v ${PWD}/InitSDLBInterface.scala:/mnt/InitSDLBInterface.scala --entrypoint="spark-shell" -w /mnt sdl-spark:latest --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.shuffle.partitions=2 --conf spark.databricks.delta.snapshotPartitions=2 --driver-java-options="-Duser.dir=/mnt/data" --driver-class-path "/opt/app/lib/*:/mnt/lib/*" -i shell.scala -i InitSDLBInterface.scala $@
