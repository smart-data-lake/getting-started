#
# Build stage
#
FROM maven:3.9.6-eclipse-temurin-17 AS build
COPY src /opt/app/src
COPY pom.xml /opt/app
RUN mvn --quiet -f /opt/app/pom.xml -Pcopy-libs-with-spark "-Dmaven.repo.local=/mnt/.mvnrepo" package

#
# Package stage
# Note that getting-started.jar is provided to the docker image through /mnt/lib and added to the class-path for SDL.
#
FROM eclipse-temurin:17
COPY --from=build /opt/app/target/lib/*.jar /opt/app/lib/
COPY src/main/resources/log4j2.yml /opt/app/lib/
COPY spark/entrypoint.sh /opt/app/entrypoint.sh
RUN chmod +x /opt/app/entrypoint.sh

ENTRYPOINT ["/opt/app/entrypoint.sh"]
