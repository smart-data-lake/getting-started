package io.test

import org.scalatest.FunSuite
import org.apache.spark.sql
import org.apache.spark.sql.SparkSession

class DataTest extends FunSuite {
  val spark: SparkSession = SparkSession.builder()
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
    .master("local[1]")
    .appName("data explorer")
    .getOrCreate()

  test("prints table") {
    val df_airports = spark.read.parquet("./data/int_departures")
    df_airports.cache()
    df_airports.show()
    print("### int_departures has currently ", df_airports.count(), " number of rows")
  }

  test("read deltalake vacuum and history"){
    import io.delta.tables._
    val deltaTable = DeltaTable.forPath(spark, "data/int_departures")
    //spark.conf.set("spark.databricks.delta.retentionDurationCheck.enabled", "false")
    //deltaTable.vacuum(0).show(false)
    //deltaTable.history().show(false)
    deltaTable.toDF.show()
  }
  test("read deltalake count"){
    import io.delta.tables._
    val deltaTable = DeltaTable.forPath(spark, "data/int_departures")
    while(true) {
      Thread.sleep(10000)
      println(deltaTable.toDF.count())
    }
  }
}