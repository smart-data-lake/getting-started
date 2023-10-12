package io.test

import org.scalatest.FunSuite
import org.apache.spark.sql
import org.apache.spark.sql.SparkSession

class DataTest extends FunSuite {
  val spark: SparkSession = SparkSession.builder()
    .master("local[1]")
    .appName("data explorer")
    .getOrCreate()

  test("read deltalake vacuum and history") {
    import io.delta.tables._
    val deltaTable = DeltaTable.forPath(spark, "data/int_departures")
    //spark.conf.set("spark.databricks.delta.retentionDurationCheck.enabled", "false")
    //deltaTable.vacuum(0).show(false)
    //deltaTable.history().show(false)
    deltaTable.toDF.show()
  }
  test("read deltalake count") {
    import io.delta.tables._
    val deltaTable = DeltaTable.forPath(spark, "data/int_departures")
    while (true) {
      Thread.sleep(10000)
      println(" int_departures has currently" + deltaTable.toDF.count() + " number of rows")
    }
  }
}