#
# Build stage
#
FROM maven:3.6.0-jdk-11-slim AS build
#copy your m2 repository in m2repo to use the following, and build a locally installed version of the io.smartdatalake:
#COPY m2repo/io/smartdatalake/* /home/app/m2repo/io/smartdatalake 

COPY src /home/app/src
COPY pom.xml /home/app
#RUN mvn -Dmaven.repo.local=/home/app/m2repo -f /home/app/pom.xml -Phadoop-3.2 package
RUN mvn -f /home/app/pom.xml -Phadoop-3.2 package

#
# Package stage
#
FROM openjdk:11-jre-slim
COPY --from=build /home/app/target/SDL-1.0.jar /opt/app/SDL.jar
COPY --from=build /home/app/target/lib/*.jar /opt/app/lib/
COPY project.jar /opt/app/lib/project.jar
COPY sqljdbc/mssql-jdbc-9.4.1.jre11.jar /opt/app/lib/
ENTRYPOINT ["java","-Dlog4j.configuration=file:///mnt/config/log4j.properties","-Duser.dir=/mnt/data","-cp","/opt/app/project.jar:/opt/app/lib/*:/mnt/config/log4j.properties","io.smartdatalake.app.LocalSmartDataLakeBuilder"]