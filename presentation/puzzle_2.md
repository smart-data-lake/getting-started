
# Puzzle #2 code blocks


---
<details>
<summary>Code Block 1</summary>

<sub>

```
    metadata {
      name = "Airport historization and filter"
      description = "Filter name and coordinates of airports and hisorize data"
      tags = ["historize", "filter", "DeltaLake"]
      feed = historize-airport
    }

```
</sub>

</details>

---

<details>
<summary>Code Block 2</summary>

<sub>

```
    metadata {
      name = "Airport elevation"
      description = "Write airport elevation in meters to Parquet file"
      feed = download-airport
    }
```

</sub>

</details>

---

<details>
<summary>Code Block 3</summary>

<sub>

```
    metadata {
      name = "Staging file of Airport location data"
      description = "contains beside GPS coordiantes, elevation, continent, country, region"
      layer = "staging"
      subjectArea = "airports"
      tags = ["aviation", "airport", "location"]
    }
```
</sub>

</details>

---


<details>
<summary>Code Block 4</summary>

<sub>

```
${env.datalakeprefix}
```
</sub>

</details>

---


<details>
<summary>Code Block 5</summary>

<sub>

```
${templates.dataLake}
```
</sub>

</details>

---

<details>
<summary>Code Block 6</summary>

<sub>

```
    metadata {
      name = "Airport locations"
      description = "airport names and locations"
      layer = "integration"
      subjectArea = "airports"
      tags = ["aviation", "airport", "location"]
    }
```
</sub>

</details>

---

<details>
<summary>Code Block 7</summary>

<sub>

```
   metadata {
     name = "Airport injection"
     description = "download airport data and write into CSV"
     tags = ["download", "websource"]
     feed = download-airport
   }
```
</sub>

</details>

---

<details>
<summary>Code Block 8</summary>

<sub>

```
    metadata {
      name = "Calculated Airport elevation in meters"
      description = "contains beside GPS coordiantes, elevation, continent, country, region"
      layer = "staging"
      subjectArea = "airports"
      tags = ["aviation", "airport", "location"]
    }
```
</sub>

</details>

---



