/*
 * Smart Data Lake - Build your data lake the smart way.
 *
 * Copyright © 2019-2025 ELCA Informatique SA (<https://www.elca.ch>)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

package io.smartdatalake

import com.fasterxml.jackson.annotation.JsonInclude.Include
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory
import com.fasterxml.jackson.dataformat.yaml.YAMLGenerator.Feature
import com.fasterxml.jackson.module.scala.DefaultScalaModule
import io.smartdatalake.URN.URNString
import io.smartdatalake.app.{BuildVersionInfo, SmartDataLakeBuilderConfig, UploadDefaults}
import io.smartdatalake.config.{ConfigToolbox, ConfigurationException}
import io.smartdatalake.meta.configexporter.ConfigJsonExporter
import io.smartdatalake.util.misc._
import io.smartdatalake.workflow.action.SDLExecutionId
import io.smartdatalake.workflow.dataframe.spark.SparkSchema
import io.smartdatalake.workflow.dataobject._
import io.smartdatalake.workflow.{ActionPipelineContext, ExecutionPhase}
import org.apache.spark.sql.confluent.avro.AvroSchemaConverter
import scopt.OptionParser

import java.nio.file.{Files, Paths, StandardOpenOption}
import java.time.LocalDateTime
import scala.util.{Failure, Success, Try}

case class DatahubYamlExporterConfig(configPaths: Seq[String] = null,
                                     target: String = "file:./datahubExport",
                                     includeRegex: String = ".*",
                                     excludeRegex: Option[String] = None,
                                     project: String = "-",
                                     environment: String = "-",
                                     platform: Option[String] = None,
                                     master: String = "local[2]"
                                )

object DatahubYamlExporter extends SmartDataLakeLogger {

  val appType: String = getClass.getSimpleName.replaceAll("\\$$", "") // remove $ from object name and use it as appType

  protected val parser: OptionParser[DatahubYamlExporterConfig] = new OptionParser[DatahubYamlExporterConfig](appType) {
    override def showUsageOnError: Option[Boolean] = Some(true)

    opt[String]('c', "config")
      .required()
      .action((value, c) => c.copy(configPaths = value.split(',')))
      .text("One or multiple configuration files or directories containing configuration files for SDLB, separated by comma.")
    opt[String]('t', "target")
      .action((value, c) => c.copy(target = value))
      .text("Target URI to export configuration to. Can be 'file:./exportPath', or Datahub http/https URL. Default: file:./datahubExport")
    opt[String]('i', "includeRegex")
      .action((value, c) => c.copy(includeRegex = value))
      .text("Regular expression used to include DataObjects in export, matching DataObject ids. Default: .*")
    opt[String]('e', "excludeRegex")
      .action((value, c) => c.copy(excludeRegex = Some(value)))
      .text("Regular expression used to exclude DataObjects from export, matching DataObject ids. `excludeRegex` is applied after `includeRegex`. Default: no excludes")
    opt[String]("project")
      .action((value, c) => c.copy(project = value))
      .required()
    opt[String]("environment")
      .action((value, c) => c.copy(environment = value))
      .required()
    opt[String]("platform")
      .action((value, c) => c.copy(platform = Some(value)))
    opt[String]('m', "master")
      .action((value, c) => c.copy(master = value))
      .text("Spark session master configuration. As schemas might be inferred by Spark, there might be a need to tune this for some DataObjects. Default: local[2]")
    help("help").text("Export DataObject schemas and statistics as Json documents which can be used by the visualizer. Each Json document is identified by its type (schema or stats), the DataObject Id and the timestamp of creation.")
  }

  /**
   * Takes as input an SDL Config and exports the schema of all DataObjects for Datahub though the Java Emitter API
   * see also https://docs.datahub.com/docs/metadata-integration/java/as-a-library
   */
  def main(args: Array[String]): Unit = {
    // Parse all command line arguments
    parser.parse(args, DatahubYamlExporterConfig()) match {
      case Some(exporterConfig) =>

        // export data object schemas and statistics to json format
        logger.info(s"starting with configuration ${ProductUtil.formatObj(exporterConfig)}")
        exportDataObjectsAsDatasets(exporterConfig)

      case None =>
        logAndThrowException(s"Aborting $appType after error", new ConfigurationException("Couldn't set command line parameters correctly."))
    }
  }

  def exportDataObjectsAsDatasets(config: DatahubYamlExporterConfig): Unit = {

    // get DataObjects
    val (registry, globalConfig) = ConfigToolbox.loadAndParseConfig(config.configPaths)
    val hadoopConf = globalConfig.getHadoopConfiguration
    implicit val context: ActionPipelineContext = ActionPipelineContext("feedTest", "appTest", SDLExecutionId.executionId1, registry, Some(LocalDateTime.now()), SmartDataLakeBuilderConfig("DataObjectSchemaExporter", Some("DataObjectSchemaExporter"), master = Some(config.master)), phase = ExecutionPhase.Init, serializableHadoopConf = new SerializableHadoopConfiguration(hadoopConf), globalConfig = globalConfig)
    val dataObjects = registry.getDataObjects
      .filter(d => d.id.id.matches(config.includeRegex) && (config.excludeRegex.isEmpty || !d.id.id.matches(config.excludeRegex.get)))

    // prepare downstream relations
    def toURN(dataObject: DataObject) = URN(config.project, dataObject, config.environment)
    val downstreamDataObjects = registry.getActions
      .flatMap(a => prod(a.inputs.map(toURN), a.outputs.map(toURN)))
      .groupBy(_._1).mapValues(_.map(_._2).distinct)

    logger.info(s"Writing ${dataObjects.size} DataObjects as Dataset to target ${config.target}")

    // get and write Datasets
    dataObjects.foreach { dataObject =>

      val urn = URN(config.project, dataObject, config.environment)
      val subtype = "(Table|View|Topic)".r.findFirstMatchIn(urn.tpe).map(_.group(0))
      val table = Option(dataObject).collect{case x: TableDataObject => x.table}
      val partitions = Option(dataObject).collect{case x: CanHandlePartitions => x.partitions}
      val path = Option(dataObject).collect{case x: FileRefDataObject => x.getPath}
      val downstreams = downstreamDataObjects.get(urn).toSeq.flatten
        .map(_.toURNString)

      // prepare schema
      logger.info(s"get schema for ${dataObject.id} (${dataObject.getClass.getSimpleName})")
      val exportedSchema = dataObject match {
        case dataObject: SparkFileDataObject =>
          val schema = Try(dataObject.getSchema)
          schema match {
            case Success(None) =>logger.info(s"${dataObject.id} of type ${dataObject.getClass.getSimpleName} did not return a schema")
            case Failure(ex) => logger.warn(s"Error getting schema for ${dataObject.id}: ${ex.getClass.getSimpleName}: ${ex.getMessage}")
            case _ => Unit
          }
          schema.toOption.flatten
        case dataObject: CanCreateDataFrame =>
          val schema = Try(dataObject.getDataFrame(Seq(), dataObject.getSubFeedSupportedTypes.head).schema)
          schema.failed.toOption.foreach(ex => s"Error getting schema for ${dataObject.id}: ${ex.getClass.getSimpleName}: ${ex.getMessage}")
          schema.toOption
        case _ => None
      }
      val schema = exportedSchema.map { schema =>
        val avroSchema = schema match {
          case schema1: SparkSchema => Some(AvroSchemaConverter.toAvroType(schema1.inner))
          case _ => None
        }
        val avroSchemaFile = avroSchema.map { schema =>
          val filename = s"${urn.id}.schema.avsc"
          writeFile(config, filename, schema.toString(true))
          filename
        }
        val fields = schema.fields.map{ f =>
          SchemaField(
            id = f.name, description = f.comment,
            isPartOfKey = table.flatMap(_.primaryKey).map(_.contains(f.name)),
            isPartitioningKey = partitions.map(_.contains(f.name))
          )
        }.filter(f => f.description.isDefined || f.isPartOfKey.contains(true) || f.isPartitioningKey.contains(true))
        Schema(fields = fields, file = avroSchemaFile)
      }

      // prepare dataset
      val dataset = Dataset(
        id = urn.id, platform = urn.platform, env = urn.environment,
        name = dataObject.metadata.flatMap(_.name),
        description = dataObject.metadata.flatMap(_.description),
        subtype = subtype,
        tags = dataObject.metadata.toSeq.flatMap(_.tags),
        properties = Seq(
          table.map("table" -> _.fullName),
          path.map("path" -> _),
          dataObject.metadata.flatMap(_.layer).map("layer" -> _),
          Some("version" -> getAppVersion())
        ).flatten.toMap,
        schema = schema,
        downstreams = downstreams
      )

      mapper.writeValue(getPath(config, s"dataset.${dataObject.id.id}.yaml").toFile, dataset);
    }
  }

  val mapper = new ObjectMapper(new YAMLFactory().disable(Feature.WRITE_DOC_START_MARKER))
  mapper.registerModule(DefaultScalaModule)
  mapper.setSerializationInclusion(Include.NON_EMPTY)

  def getPath(config: DatahubYamlExporterConfig, name: String) = {
    val root = Paths.get(config.target.stripPrefix("file:"))
    Files.createDirectories(root)
    root.resolve(name)
  }

  def getAppVersion(): String = {
    BuildVersionInfo.appVersionInfo.map(_.version).getOrElse(UploadDefaults.versionDefault)
  }

  /**
   * cross product between two lists
   */
  def prod[X](a: Seq[X], b: Seq[X]): Seq[(X,X)] = {
    for { i1 <- a ; i2 <- b } yield (i1, i2)
  }

  def writeFile(config: DatahubYamlExporterConfig, name: String, content: String): Unit = {
    Files.write(getPath(config, name), content.getBytes, StandardOpenOption.WRITE, StandardOpenOption.TRUNCATE_EXISTING, StandardOpenOption.CREATE)
  }

}


case class URN(entity: String, tpe: String, platform: String, id: String, environment: String) {
  def toURNString: URNString = s"urn:li:dataset:(urn:li:dataPlatform:$platform,$id,$environment)"
}
object URN {
  def apply(project: String, dataObject: DataObject, environment: String): URN = {
    val tpe = dataObject.getClass.getSimpleName
    URN("dataset", tpe, tpe.take(tpe.indexWhere(_.isUpper, 1)).toLowerCase, project + "." + dataObject.id.id, environment)
  }
  type URNString = String
}


case class SchemaField(
                      id: String, `type`: Option[String] = None, description: Option[String] = None,
                      nativeDataType: Option[String] = None, nullable: Option[Boolean] = None,
                      label: Option[String] = None, globalTags: Seq[String] = Seq(), glossaryTerms: Seq[URNString] = Seq(),
                      isPartOfKey: Option[Boolean] = None, isPartitioningKey: Option[Boolean] = None,
                      jsonProps: Map[String,Any] = Map(),
                      structured_properties: Map[String,Any] = Map()
                      )

case class Schema(fields: Seq[SchemaField] = Seq(), file: Option[String] = None)

case class Owner(id: String, `type`: String = "TECHNICAL_OWNER")

case class Dataset(
                    id: String, platform: String, env: String,
                    name: Option[String] = None, description: Option[String] = None,
                    schema: Option[Schema] = None,
                    subtype: Option[String] = None,
                    glossary_terms: Seq[URNString] = Seq(),
                    owners: Seq[Owner] = Seq(),
                    downstreams: Seq[URNString] = Seq(),
                    tags: Seq[String] = Seq(),
                    structured_properties: Map[String,Any] = Map(),
                    properties: Map[String,Any] = Map(),
                    external_url: Option[String] = None
                  )