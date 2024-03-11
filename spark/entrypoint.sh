#!/bin/bash

# define java class to start
CLASS=${CLASS:-io.smartdatalake.app.LocalSmartDataLakeBuilder}
echo "starting $CLASS"

# Java options needed by Spark for Java 17
JAVA_OPTIONS="--add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED --add-opens=java.base/jdk.internal.ref=ALL-UNNAMED --add-opens=java.base/sun.nio.cs=ALL-UNNAMED --add-opens=java.base/sun.security.action=ALL-UNNAMED --add-opens=java.base/sun.util.calendar=ALL-UNNAMED"

# start SDLB with java command line
java $JAVA_OPTIONS -Duser.dir=/mnt/data -Dlog4j2.configurationFile=file:/opt/app/lib/log4j2.yml -cp /opt/app/lib/*:/mnt/lib/* $CLASS $@
