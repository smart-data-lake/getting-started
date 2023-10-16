
# Puzzle #3 code blocks

---
<details>
<summary>Code Block 1</summary>


```
    constraints = [{
      name = Departure Airport should be different from Arrival Aiport
      description = "A flight from A to A makes no sense"
      expression = "arrivalairport != departureairport"
      errorMsgCols = [departureairport,arrivalairport, arr_name, arr_latitude_deg, arr_longitude_deg, dep_name, dep_latitude_deg, dep_longitude_deg, could_be_done_by_rail]
    }]
```

</details>

---
<details>
<summary>Code Block 2</summary>


```
    expectations = [{
      type = SQLFractionExpectation
      name = RailPessimist
      description = "most flights could be replaced by rail"
      expectation = "0"
      failedSeverity = "Warn"
    }]

```

</details>

---
<details>
<summary>Code Block 3</summary>


```
    constraints = [{
      name = Departure Airport should be different from Arrival Aiport
      description = "A flight from A to A makes no sense"
      expression = "estarrivalairport != estdepartureairport"
      errorMsgCols = [estdepartureairport,estarrivalairport, arr_name, arr_latitude_deg, arr_longitude_deg, dep_name, dep_latitude_deg, dep_longitude_deg,could_be_done_by_rail]
    }]

```

</details>

---

<details>
<summary>Code Block 4</summary>



```
    expectations = [{
      type = SQLFractionExpectation
      name = RailPessimist
      description = "most flights could be replaced by rail"
      countConditionExpression = "could_be_done_by_rail = true"
      expectation = "< 0.5"
      failedSeverity = "Warn"
    }]

```

</details>







