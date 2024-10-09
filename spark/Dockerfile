ARG SCALA_VERSION="2.12"
ARG SPARK_VERSION="3.5"

#
# Build stage
#
FROM docker.io/maven:3-eclipse-temurin-17 AS build
COPY ../src /opt/app/src
COPY pom.xml /opt/app
RUN mvn --quiet -f /opt/app/pom.xml -Pcopy-libs -Pscala-$SCALA_VERSION -Dmaven.repo.local=/mnt/.mvnrepo dependency:copy-dependencies@copy-libs-exec

#
# Package stage
# Note that getting-started.jar is provided to the docker image through /mnt/lib and added to the class-path for SDL.
#
FROM docker.io/eclipse-temurin:17
ARG SCALA_VERSION
ARG SPARK_VERSION

# install python
RUN apt-get update -y && apt-get install -y build-essential procps python3 python3-dev python3-pip wget

WORKDIR /opt

# get latest Spark version for selected minor version
RUN wget -q -O - https://dlcdn.apache.org/spark/ | grep -o 'href=".*">' | sed 's/href="//;s/\/">//' | grep "spark-"$SPARK_VERSION | sed 's/spark-//' > /opt/spark.version
RUN bash -l -c 'echo export SCALA_VERSION="$(cat /opt/spark.version)" >> /etc/bash.bashrc'

# install spark distribution (polynote needs spark-submit command)
COPY spark/install_spark.sh .
RUN chmod +x install_spark.sh && SPARK_VERSION=$(cat /opt/spark.version) spark/install_spark.sh
ENV SPARK_HOME="/opt/spark"
ENV PATH="$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin"

# copy sdl libraries
COPY --from=build /opt/app/target/lib/*.jar /opt/app/lib/
COPY src/main/resources/log4j2.yml /opt/app/
COPY spark/entrypoint.sh /opt/app/entrypoint.sh
RUN chmod +x /opt/app/entrypoint.sh

ENTRYPOINT ["/opt/app/entrypoint.sh"]
