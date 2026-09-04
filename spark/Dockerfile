# Spark minor version to install. Only the patch level is left open as dlcdn mirror keeps just the
# latest patch release of each supported minor version.
# Keep this aligned with spark.minor.version in sdl-parent (4.1 for SDLB 3.0.0) - the
# SDL libraries copied in below are compiled against it, and every Spark jar on the classpath
# comes from this distribution rather than from /opt/app/lib.
# A fully qualified version (--build-arg SPARK_VERSION=4.1.1) is installed as given.
ARG SPARK_VERSION="4.1"

#
# Build stage
# Only pom.xml is needed: copy-libs resolves the SDL dependencies and does not compile this
# project, whose own jar reaches the container through the /mnt/lib mount.
#
FROM docker.io/maven:3-eclipse-temurin-17 AS build
COPY pom.xml /opt/app/
RUN mvn --quiet -f /opt/app/pom.xml -Pcopy-libs -Dmaven.repo.local=/mnt/.mvnrepo dependency:copy-dependencies@copy-libs-exec

# Record the exact Spark version this project builds against, for the check in the next stage.
# The grep keeps maven's warning lines out of the file.
RUN mvn --quiet -f /opt/app/pom.xml -Dmaven.repo.local=/mnt/.mvnrepo \
      -Dexpression=spark.version -DforceStdout help:evaluate \
      | tr -d ' \r' | grep -E '^[0-9]+[.][0-9]+[.][0-9]+$' | tail -1 > /opt/app/spark.version \
 && test -s /opt/app/spark.version \
 && echo "project builds against Spark $(cat /opt/app/spark.version)"

#
# Package stage
# Note that getting-started.jar is provided to the docker image through /mnt/lib and added to the class-path for SDL.
#
FROM docker.io/eclipse-temurin:17
ARG SPARK_VERSION

# procps: Spark's shell scripts need ps. The python3 packages are what PySpark uses for Arrow
# and pandas interop - nothing in this tutorial needs them, but the image is also used for
# spark-shell and notebooks. They come from apt rather than pip because Ubuntu marks its Python
# environment externally managed (PEP 668).
RUN apt-get update -y \
 && apt-get install --upgrade -y procps python3 python3-numpy python3-pandas python3-pyarrow wget \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# Resolve the patch level of the selected minor version, taking the newest release dlcdn offers.
# Anchoring the match to "spark-<minor>.<patch>/" and taking the last version-sorted entry
RUN set -eu; \
    case "$SPARK_VERSION" in \
      *.*.*) version="$SPARK_VERSION" ;; \
      *) version=$(wget -q -O - https://dlcdn.apache.org/spark/ \
           | tr '"' '\n' \
           | grep -E "^spark-${SPARK_VERSION}[.][0-9]+/$" \
           | sed 's|^spark-||; s|/$||' \
           | sort -V | tail -1) ;; \
    esac; \
    test -n "$version"; \
    echo "$version" > /opt/spark.version; \
    echo "installing Spark $version"

# Warn when the distribution and the jars in /opt/app/lib disagree on the Spark patch version.
COPY --from=build /opt/app/spark.version /opt/spark.project.version
RUN set -eu; \
    installed=$(cat /opt/spark.version); project=$(cat /opt/spark.project.version); \
    if [ "$installed" != "$project" ]; then \
      echo "WARNING: installing Spark $installed, but the project builds against Spark $project."; \
      echo "WARNING: if the pipeline fails to link, rebuild with --build-arg SPARK_VERSION=$project"; \
    fi

# install spark distribution (spark-submit is also what a Spark shell or a notebook kernel uses)
# The sed strips CR characters: .gitattributes asks for LF, but a working tree that was
# checked out before that rule still carries CRLF
COPY spark/install_spark.sh /opt
RUN sed -i 's/\r$//' /opt/install_spark.sh \
 && chmod +x /opt/install_spark.sh \
 && SPARK_VERSION=$(cat /opt/spark.version) /opt/install_spark.sh
ENV SPARK_HOME="/opt/spark"
ENV PATH="$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin"

# copy sdl libraries
COPY --from=build /opt/app/target/lib/*.jar /opt/app/lib/
COPY src/main/resources/log4j2.yml /opt/app/
COPY spark/entrypoint.sh /opt/app/entrypoint.sh
RUN sed -i 's/\r$//' /opt/app/entrypoint.sh && chmod +x /opt/app/entrypoint.sh

ENTRYPOINT ["/opt/app/entrypoint.sh"]
