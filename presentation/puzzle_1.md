
# Possible Data Objects


---
<details>
<summary>Data Object 1</summary>



```
  int-airports {
      type = CsvFileDataObject
      path = "data/~{id}"
      table {
          db = "default"
          name = "int_airports"
          primaryKey = [ident]
      }
  }

```


</details>

---

<details>
<summary>Data Object 2</summary>



```
  int_airports {
      type = DeltaLakeTableDataObject
      path = "data/~{id}"
      table {
          db = "default"
          name = "int_airports"
          primaryKey = [ident]
      }
  }
```



</details>

---

<details>
<summary>Data Object 3</summary>



```
  btl_elevation { 
    type = CsvFileDataObject
    sparkRepartition { #This will create only one .csv file and not many!
      numberOfTasksPerPartition=1
      filename="elevation.csv"
    }
    csvOptions {
      mode=failfast
    }
  }
```


</details>

---


<details>
<summary>Data Object 4</summary>



```
  btl_airports_elevation { 
    type = CsvFileDataObject
    path = ${env.datalakeprefix}"/~{id}"
    sparkRepartition { #This will create only one .csv file and not many!
      numberOfTasksPerPartition=1
      filename="elevation.csv"
    }
    csvOptions {
      mode=failfast
    }
  }
```

</details>

---

<details>
<summary>Data Object 5</summary>



```
  ext-airports-table {
    type = JDBCTableDataObject
    connectionId = elevationServerConnection
    db = "elevation_db"
    table = {
      name = "Hinweis"
    }
  }
```

</details>

---

#  Possible Actions

<details>
<summary>Action 1</summary>



```
  export-elevations {
    type = CopyAction
    inputId = btl_airports_elevation
    outputId = stg_airports
    transformers = [{
      type = SQLDfTransformer
      code = "select name, elevation_ft, (elevation_ft / 3.281) as elevation_meters from stg_airports" #Tricky, do not use comma but decimal point ;-)
    }]
  }
```

</details>

---

<details>
<summary>Action 2</summary>


```
  export-airport-elevations {
    type = CopyAction
    inputId = stg_airports
    outputId = btl_airports_elevation
    transformers = [{
      type = SQLDfTransformer
      code = "select name, elevation_ft, (elevation_ft / 3.281) as elevation_meters from stg_airports" #Tricky, do not use comma but decimal point ;-)
    }]
  }
```

</details>

---

<details>
<summary>Action 3</summary>


```
  transform-airports {
    type = HistorizeAction
    inputId = stg_airports
    outputId = int_airports
    transformers = [{
      type = SQLDfTransformer
      SQLScript = "select ident, name, latitude_deg, longitude_deg from stg_airports"
    }]
  }
```

</details>

---

<details>
<summary>Action 4</summary>


```
  historize-airports {
    type = HistorizeAction
    inputId = stg_airports
    outputId = int_airports
    transformers = [{
      type = SQLDfTransformer
      code = "select ident, name, latitude_deg, longitude_deg from stg_airports"
    }]
  }
```

</details>

---


