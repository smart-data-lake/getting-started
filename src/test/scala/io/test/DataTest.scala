package io.test

import org.scalatest.FunSuite
import org.apache.spark.sql
import org.apache.spark.sql.SparkSession

class DataTest extends FunSuite {
  val spark: SparkSession = SparkSession.builder()
    .master("local[1]")
    .appName("data explorer")
    .getOrCreate()

  test("prints table") {
    val df_airports = spark.read.parquet("./data/int_departures")
    df_airports.cache()
    df_airports.show()
    print("### int_departures has currently ", df_airports.count(), " number of rows")
  }
}