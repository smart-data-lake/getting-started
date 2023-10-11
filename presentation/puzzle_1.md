
# Possible Data Objects


---
<details>
<summary>Data Object 1</summary>

<sub>

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
</sub>

</details>

---

<details>
<summary>Data Object 2</summary>

<sub>

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

</sub>

</details>

---

<details>
<summary>Data Object 3</summary>

<sub>

```
  btl_airports_elevation {
    type = CsvFileDataObject
    path = "data/~{id}"
    csvOptions {
      mode=failfast 
    }
  }
```
</sub>

</details>

---


<details>
<summary>Data Object 4</summary>

<sub>

```
  btl_elevation {
    type = CsvFileDataObject
    csvOptions {
      mode=failfast 
    }
  }
```
</sub>

</details>

---

#  Possible Actions

<details>
<summary>Action 1</summary>

<sub>

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
</sub>

</details>

---

<details>
<summary>Action 2</summary>

<sub>

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
</sub>

</details>

---

<details>
<summary>Action 3</summary>

<sub>

```
  transform-airports {
    type = HistorizeAction
    inputId = stg_airports
    outputId = int_airports
    transformers = [{
      type = SQLDfTransformer
      SQLCode = "select ident, name, latitude_deg, longitude_deg from stg_airports"
    }]
  }
```
</sub>

</details>

---

<details>
<summary>Action 4</summary>

<sub>

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
</sub>

</details>

---



