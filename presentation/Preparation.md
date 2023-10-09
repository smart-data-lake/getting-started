# Preparation

Welcome! Please follow the steps outlined in this document to complete the technical set-up of the Smart Data Lake Builder (SDLB).

## What you will need

The following technical requirements are needed in order to participate in the training. Your system may already have some of these installed:
- Java / **JDK 11** --> The SDLB is a framework programmed in Scala and it runs on the Java Virtual Machine.
- Hadoop --> A framework for distributed storage (needs to be separately installed).
- Intellij (with some plugins) --> Integrated Development Environment (IDE) where you will develop, build and run your data pipelines. In this guide we will install IntelliJ and its add-ons and will make sure that the project can build correctly.


This guide assumes that you're working on a Windows machine. The setup for Linux or MacOS generally comprises the same steps.

*IMPORTANT: Please make sure that the three steps are carried out in the order outlined below, i.e. install Java before installing Hadoop, and install Hadoop before installing and opening IntelliJ.*

### Installing Java
Most Windows machines come with Java already installed. In order to check if you have Java installed on your machine, open your PowerShell and type `java --version` and then ENTER. The output should look similar to this:

```
openjdk 11.0.3 2019-04-16
OpenJDK Runtime Environment AdoptOpenJDK (build 11.0.3+7)
OpenJDK 64-Bit Server VM AdoptOpenJDK (build 11.0.3+7, mixed mode)
``` 

In the case above, the machine is running Java 11 per default. If you see a similar message (with Java version 11 or newer), you are all set with this step and can continue with the next section (Installing Hadoop).

**If the command above wasn't found by your machine**, you'll have to install Java. To do this, click on [this link](https://learn.microsoft.com/en-us/java/openjdk/download) and install Java, for example using the Windows installer

**If your Java version is different from Java 11**, you have to install a this version (as described above) and update the default version being used by your OS. For this, please refer to the guide on [this link](https://www.happycoders.eu/java/how-to-switch-multiple-java-versions-windows/).

Type `java --version` again to double-check that the installation was carried out successfully.

### Installing Hadoop

If you already have Hadoop installed, you should be able to see its version with `hadoop version` in the terminal. If the command was not found, follow these steps:

1. Download the binaries of the latest release [here](https://github.com/cdarlint/winutils/archive/refs/heads/master.zip).

2. Choose the version that you like best and extract it into a folder on wour machine. For example, you can extract the version 3.2.2 into the root of the C:/ directory as shown in the screenshot.

<img src="/presentation/images/hadoop_binaries.png" width="50%" height="50%">

1. Change the PATH and HADOOP_HOME environment variables:
   1. Go to System Properties --> Advanced System Settings --> Environment Variables

  <img src="/presentation/images/advanced_system_settings.png" width="60%" height="60%">

2. Create a new user variable HADOOP_HOME and set its value to the path of where you stored the Hadoop binaries in the previous step.

<img src="/presentation/images/hadoop_home_var.png" width="60%" height="60%">

3. Add the same folder to the PATH variable including the */bin* suffix.

![](/presentation/images/hadoop_bins_1.png)

2. Test the results with `hadoop version` in your terminal. You may have to restart your computer for the changes to take place.


### Installing IntelliJ and building the project

IntelliJ is the Integrated Development Environment (IDE) where we are going to do most of the work. It provides a very intuitve graphical interface for developing, building and running Java applications and it comes with lots of useful plugins.

1. Please download and install IntelliJ from the [official website](https://www.jetbrains.com/idea/download). The free Community Edition is more than enough for performing th tasks in this course.
2. Run IntelliJ and install the following plugins (you can do this either directly after opening IntelliJ or by going to File --> Settings --> Plugins)
   1. Scala
   2. Avro and Parquet Viewer

3. Do not create a new project. Instead, click on *Get from VSC* and paste the following github URL from the training:

`https://github.com/smart-data-lake/getting-started.git`

<img src="/presentation/images/get_from_vcs.png" width="30%" height="30%">

4. Checkout the *training* branch from the cloned repository. For this, go the git tab, right-click on the *training* branch, and click on *checkout*.

<img src="/presentation/images/checkout_branch.png" width="40%" height="40%">

5. Add the module as a Maven project by right-clicking on the *pom.xml* file and selecting *Add Maven as a Project*.

<img src="/presentation/images/addmaven.png" width="40%" height="40%">

6. Make a test run by changing the runConfigurations to *SDLB_test* and clicking on the *Play* button. A successful build and run should show you the SDLB options and end with an exit code 0 as shown in the screenshot.
   When the class can not be found: right-click on the file pom.xml -> Add as Maven project. The first run will build the framework which could take a few minutes.

![](/presentation/images/runtest.png)

At the end of the output you should see: `Process finished with exit code 0`

That's it! Now you're all set up for the upcoming training.
