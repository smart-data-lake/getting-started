# Databricks notebook source
# MAGIC %md
# MAGIC # Running SDLB on Databricks
# MAGIC This is a Databricks Notebook to install and demonstrate SDLB on Databricks.
# MAGIC See recent Blog Post on https://smartdatalake.ch/blog for detailled explanations.
# MAGIC
# MAGIC Use the Widgets above to configure most important parameters.

# COMMAND ----------

# MAGIC %md
# MAGIC ## Install maven
# MAGIC Maven is needed to compile Java source file and create a Jar-Archive file containing all libraries used for this project (see also dependencies in pom.xml).

# COMMAND ----------

import os
# write widgets parameters into a shell script
#params = dbutils.widgets.getAll() # error No module named 'delta.exceptions.captured'; 'delta.exceptions' is not a package
params = {param: dbutils.widgets.get(param) for param in ["REPODIR", "TMPDIR", "VOLDIR"]}
f = open("/tmp/getting-started-env.sh", "w")
for key, value in params.items():
  f.write(f"export {key}={value}\n")
f.close()
os.chmod("/tmp/getting-started-env.sh", 0o775) # make it executable

# COMMAND ----------

# MAGIC %sh
# MAGIC # Java version should be 17, otherwise set cluster environment variable JNAME=zulu17-ca-amd64 
# MAGIC java --version

# COMMAND ----------

# MAGIC %sh
# MAGIC # install maven
# MAGIC apt update
# MAGIC apt install -y maven

# COMMAND ----------

# MAGIC %md
# MAGIC ## Prepare Getting Started Config and Jar file
# MAGIC Lets copy config files, source code and pom.xml to a temporary directory. Then start Maven build to create the Jar-Archive.
# MAGIC Finally copy Jar-Archive to Unity Catalog Volume, so it is accessible by Job and Cluster.

# COMMAND ----------

# MAGIC %sh
# MAGIC . /tmp/getting-started-env.sh # set env variables prepared above
# MAGIC cat /tmp/getting-started-env.sh
# MAGIC if [ -z "${TMPDIR}" ]; then echo "variable TMPDIR not defined!"; exit -1; fi
# MAGIC
# MAGIC # copy latest config files to workspace folder
# MAGIC cd $REPODIR
# MAGIC cp ./config/airports.conf.part-3-solution ./config/airports.conf
# MAGIC cp ./config/departures.conf.part-3-solution ./config/departures.conf
# MAGIC cp ./config/btl.conf.part-3-solution ./config/btl.conf
# MAGIC cp ./envConfig/databricks.conf.template ./envConfig/dev.conf
# MAGIC
# MAGIC # prepare temporary build folder on cluster
# MAGIC mkdir -p $TMPDIR
# MAGIC cd $TMPDIR
# MAGIC
# MAGIC # copy scala code to build folder
# MAGIC mkdir -p $TMPDIR/src/main/scala/com/sample/
# MAGIC cp $REPODIR/src/main/scala/com/sample/*.scala ./src/main/scala/com/sample/
# MAGIC cp $REPODIR/src/main/scala/com/sample/CustomWebserviceDataObject.scala.part-3-solution ./src/main/scala/com/sample/CustomWebserviceDataObject.scala
# MAGIC
# MAGIC # copy maven pom to build folder
# MAGIC cp $REPODIR/pom.xml .
# MAGIC
# MAGIC # copy config to build folder
# MAGIC cp -r $REPODIR/config .
# MAGIC cp -r $REPODIR/envConfig .

# COMMAND ----------

# MAGIC %sh
# MAGIC . /tmp/getting-started-env.sh # set env variables prepared above
# MAGIC cd $TMPDIR
# MAGIC mvn package -B -Pgenerate-catalog -Pfat-jar
# MAGIC cp target/getting-started-1.0.jar $VOLDIR/getting-started.jar
# MAGIC cp target/getting-started-1.0-jar-with-dependencies.jar $VOLDIR/getting-started-with-dependencies.jar

# COMMAND ----------

# MAGIC %md
# MAGIC ## Upload Configuration to UI

# COMMAND ----------

# MAGIC %scala
# MAGIC // Check keystore entries
# MAGIC import com.databricks.sdk.scala.dbutils.DBUtils
# MAGIC val dbutils = DBUtils.getDBUtils()
# MAGIC dbutils.secrets.list(scope = "my_sec").foreach(println)
# MAGIC // Upload config
# MAGIC import io.smartdatalake.meta.configexporter._
# MAGIC val repodir = dbutils.widgets.get("REPODIR")
# MAGIC ConfigJsonExporter.main(Array("--config", s"file://$repodir/config,file://$repodir/envConfig/dev.conf", "--target", "uiBackend"))

# COMMAND ----------

# MAGIC %md
# MAGIC ## Upload Schema and Statistics to UI

# COMMAND ----------

# MAGIC %scala
# MAGIC // ATTENTION: run after first run!
# MAGIC // Upload schemas and statistics
# MAGIC // Statistics export is currently broken in Databricks, there seems to be a problem with DeltaSQLConf 
# MAGIC val t = org.apache.spark.sql.delta.sources.DeltaSQLConf.LOAD_FILE_SYSTEM_CONFIGS_FROM_DATAFRAME_OPTIONS
# MAGIC //import io.smartdatalake.meta.configexporter._
# MAGIC //val repodir = dbutils.widgets.get("REPODIR")
# MAGIC //DataObjectSchemaExporter.main(Array("--config", s"file://$repodir/config,file://$repodir/envConfig/dev.conf", "--target", "uiBackend"))

# COMMAND ----------

# MAGIC %md
# MAGIC ## Try SDLB Lab interface

# COMMAND ----------

# MAGIC %scala
# MAGIC // load SDLB Lab interface
# MAGIC import io.smartdatalake.generated._
# MAGIC import io.smartdatalake.lab.SmartDataLakeBuilderLab
# MAGIC val sdlb = SmartDataLakeBuilderLab[DataObjectCatalog, ActionCatalog](spark,Seq("file:///Workspace/Repos/sdlb/getting-started/config", "file:///Workspace/Repos/sdlb/getting-started/envConfig/dev.conf"), DataObjectCatalog(_, _), ActionCatalog(_, _))
# MAGIC implicit val context = sdlb.context

# COMMAND ----------

# MAGIC %scala
# MAGIC // access dataObjects via SDLB interface with Code Completion
# MAGIC // get DataFrame, schema, or drop table...
# MAGIC sdlb.dataObjects.btlDistances.printSchema
# MAGIC sdlb.dataObjects.btlDistances.get
# MAGIC .where($"could_be_done_by_rail"===true).show

# COMMAND ----------

# MAGIC %scala
# MAGIC // access actions via SDLB interface with Code Completion.
# MAGIC // play with & manipulate transformations, get resulting DataFrames.
# MAGIC sdlb.actions.computeDistances.buildDataFrames.withFilterEquals("estdepartureairport","EDDF").getOne.show

# COMMAND ----------


