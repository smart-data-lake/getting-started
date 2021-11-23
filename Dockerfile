#
# Build stage
#
FROM maven:3.6.0-jdk-11-slim AS build
COPY src /home/app/src
COPY pom.xml /home/app
RUN mvn -f /home/app/pom.xml -Phadoop-3.2 package

FROM openjdk:11-jre-slim
COPY --from=build /home/app/target/getting-started-1.0.jar /opt/app/getting-started.jar
COPY --from=build /home/app/target/lib/*.jar /opt/app/lib/
COPY myfeuerwehr-1.0.0-SNAPSHOT.jar /opt/app/lib/project.jar
ENTRYPOINT ["java","-Duser.dir=/mnt/data","-cp","/opt/app/project.jar:/opt/app/lib/*","io.smartdatalake.app.LocalSmartDataLakeBuilder"]
