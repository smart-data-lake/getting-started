
# Puzzle #2 code blocks


---
<details>
<summary>Code Block 1</summary>



```
    metadata {
      name = "Airport historization and filter"
      description = "Filter name and coordinates of airports and hisorize data"
      tags = ["historize", "filter", "DeltaLake"]
      feed = historize-airport
    }

```


</details>

---

<details>
<summary>Code Block 2</summary>



```
    metadata {
      name = "Airport elevation"
      description = "Write airport elevation in meters to Csv file"
      feed = download-airport
    }
```

</details>

---

<details>
<summary>Code Block 3</summary>


```
    metadata {
      name = "Staging file of Airport location data"
      description = "contains beside GPS coordiantes, elevation, continent, country, region"
      layer = "staging"
      subjectArea = "airports"
      tags = ["aviation", "airport", "location"]
    }
```

</details>

---


<details>
<summary>Code Block 4</summary>

```
path = ${env.datalakeprefix}"/~{id}"
```


</details>

---


<details>
<summary>Code Block 5</summary>



```
int_airports = ${templates.dataLake} {
```


</details>

---

<details>
<summary>Code Block 6</summary>



```
    metadata {
      name = "Airport locations"
      description = "airport names and locations"
      layer = "integration"
      subjectArea = "airports"
      tags = ["aviation", "airport", "location"]
    }
```


</details>

---

<details>
<summary>Code Block 7</summary>



```
   metadata {
     name = "Airport injection"
     description = "download airport data and write into CSV"
     tags = ["download", "websource"]
     feed = download-airport
   }
```


</details>

---

<details>
<summary>Code Block 8</summary>


```
    metadata {
      name = "Calculated Airport elevation in meters"
      description = "contains beside GPS coordiantes, elevation, continent, country, region"
      layer = "business transformation"
      subjectArea = "airports"
      tags = ["aviation", "airport", "location"]
    }
```

</details>

---


