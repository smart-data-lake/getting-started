#!/bin/bash
# This script is intended for use from the docker builds.

set -e

echo SparkVersion=${SPARK_VERSION:?}
SPARK_NAME="spark-${SPARK_VERSION}-bin-hadoop3"

pushd /opt
rm -rf spark

# dlcdn mirror carries only the latest patch release of each minor version, so an explicitly pinned
# older patch version (--build-arg SPARK_VERSION=4.1.1) has to fall back to the archive.
for base in "https://dlcdn.apache.org/spark" "https://archive.apache.org/dist/spark"; do
  url="${base}/spark-${SPARK_VERSION}/${SPARK_NAME}.tgz"
  echo "fetching $url"
  if wget -q -O spark.tgz "$url"; then break; fi
  rm -f spark.tgz
done
test -s spark.tgz || { echo "could not download ${SPARK_NAME}.tgz"; exit 1; }

tar xzf spark.tgz --no-same-owner
rm -f spark.tgz
mv "${SPARK_NAME}" spark
popd

if test -z "${SPARK_DIST_CLASSPATH}"; then
  echo "Skipping spark env"
else
  echo "export SPARK_DIST_CLASSPATH=\"${SPARK_DIST_CLASSPATH}\"" > /opt/spark/conf/spark-env.sh
fi
