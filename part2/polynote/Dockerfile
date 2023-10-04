# This image contains
# - polynote notebook
# - a spark distribution (because polynote needs more than spark java artifacts)
# - SDL libraries (to use SDL in notebooks)

ARG POLYNOTE_VERSION=0.5.1
# check available versions at https://spark.apache.org/downloads.html
ARG SCALA_VERSION="2.12"

#
# Build sdl-lib stage
#
FROM maven:3.6.0-jdk-11-slim AS build
COPY sdl-lib-pom.xml /home/app/
RUN mvn -f /home/app/sdl-lib-pom.xml package

#
# Package stage
#
FROM docker.io/polynote/polynote:${POLYNOTE_VERSION}-${SCALA_VERSION}

# Arguments after `FROM` are reset
ARG SCALA_VERSION="2.12"
ARG SPARK_MAJOR_VERSION="3.3"
ARG HADOOP_VERSION="3"
# derby version used by this spark version - we need to load additional derbyclient jar to connect to remote metastore
ARG DERBY_VERSION="10.14.2.0"

USER root

# check available versions at https://spark.apache.org/downloads.html
RUN wget -q -O - https://dlcdn.apache.org/spark/ | grep -o 'href=".*">' | sed 's/href="//;s/\/">//' | grep "spark-"$SPARK_MAJOR_VERSION | sed 's/spark-//' > /opt/spark.version
RUN bash -l -c 'echo export SPARK_VERSION="$(cat /opt/spark.version)" >> /etc/bash.bashrc'

WORKDIR /opt

# install spark distribution (polynote needs spark-submit command)
COPY install_spark.sh .
# convert line-endings to unix format and start script to install spark
RUN sed -i 's/\r$//' install_spark.sh && chmod +x install_spark.sh && SPARK_VERSION=$(cat /opt/spark.version) ./install_spark.sh
ENV SPARK_HOME="/opt/spark"
ENV PATH="$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin"

# copy sdl libraries
COPY --from=build /home/app/target/lib/*.jar $SPARK_HOME/jars/

# switch to non-root user
USER ${NB_USER}
