# Preparation

Welcome! Please follow the steps outlined in this document to complete the technical set-up of the Smart Data Lake Builder (SDLB). 

## What you will need

The following technical requirements are needed in order to participate in the training. Your system may already have some of these installed:
- Java / JDK 11 (or newer) --> The SDLB is a framework programmed in Scala and it runs on the Java Virtual Machine.
- Maven --> Used to build the application with all its dependencies
- Hadoop --> Framework for distributed storage (needs to be separately installed)
- Intellij (with some plugins) --> Integrated Development Environment (IDE) where you will develop, build and run your data pipelines. Scala Plugin (2.12), bigdata plugin / oder AVRO Parquet Viewer (für Parquet). 
- Node --> A backend JavaScript runtime environment that you will use to visualize your work

This guide assumes that you're working on a Windows machine. The setup for Linux or MacOS generally comprises the same steps. 

### Installing Java
Most Windows machines come with Java already installed. In order to check if you have Java installed on your machine, open your PowerShell and type `java --version` and then ENTER. The output should be something like

```
openjdk 11.0.3 2019-04-16
OpenJDK Runtime Environment AdoptOpenJDK (build 11.0.3+7)
OpenJDK 64-Bit Server VM AdoptOpenJDK (build 11.0.3+7, mixed mode)
``` 

In the case above, the machine is running Java 11 per default. If you see a similar 

