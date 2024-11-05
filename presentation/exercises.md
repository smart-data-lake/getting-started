
# SDLB Hands-On Training - Links and Exercises

----------

## Puzzles 
<details>
<summary>Click here to show the puzzle 1</summary>


It is now time to continue building our pipeline. 
We want the pipeline to do the following:

1. Download the airports data from the given link as a
.csv file. 
2. Store the airports table only with the attributes 
*identity*, _name_, _latitude degree_ and _longitude degree_ in
the **Delta Lake format**.
3. Furthermore, we want to store .csv File containing
also the airport elevation. Since we have colleagues 
both in the USA and in Europe, we want to provide 
the airport elevation both in feet and in meters. For this
file, it suffices that we provide the attributes 
_airport_name_, _elevationInFeet_ and _elevationInMeters_.

In order to build the pipeline, consider the following:
- How many data objects and actions do you need in total?
How many did we already configure?
- Which configuration fields are possible? Which ones are required?
  (Use the Schema Viewer!)
- We want to use the Lakehouse Architecture. How can the 
components be named properly?

For this exercise, you are given some [preconfigured data objects](puzzle_1.md)
and actions. The idea is that you use them to further
build your airports.config file.

> **TASK**: Copy and paste the proper data objects and actions
> into your `airports.conf` file!

</details>
<details>

<summary>Click here to show the puzzle 2</summary>


Before testing our pipeline, we want to write some metadata
into our data objects and actions. We also want to
replace some code blocks with template definitions and
environment variables. Before starting the exercise, please 
think about the following:

- Which feeds make sense? Which ones are not really useful?
- Check out the envConfig/ folder to search for some
existing templates.
- Do you have to overwrite some of the exiting code?

> **TASK**: 
> 1. Paste the [code blocks from the puzzle](puzzle_2.md) into your airports.conf file!
> Note that there are no "extra" blocks this time.
> 2. Try running your pipeline one time!
</details>

<details><summary>Click here to show the puzzle 3</summary>

Insert [the code given in puzzle 3](puzzle_3.md) in the file *distances.conf*.

Execute SDLB on partition estdepartureairport=LSZB (SDLB_data_quality):
 
`-c $ProjectFileDir$/config,$ProjectFileDir$/envConfig/local_Intellij.conf --feed-sel compute --partition-values estdepartureairport=LSZB`

Let's change the numbers to see what happens when the expectations and constraints are violated.
Notice the warning.
We will come to metrics later when we talk about state.
</details>


--------

## Homework
* split into groups of 2 or **3**
* find use case you implement next week in a 4h session
  - input: data sources (webservice or file or (local) database)
  - output: targets (simplest: CSV, or DeltaLake, or other)
  - multiple dataObjects and actions
  - suggestion: at least one transformation (more than data copy)
  - sketch dataObjects and actions with main properties/operations
  - see https://smartdatalake.ch/json-schema-viewer for inspiration

* next week:
  - first present and discuss ideas and analyze feasibility, methods to implement
  - you work together on the implementation and SDLB experts will assist you

------


## Interesting links
- [Lecture notes](https://github.com/smart-data-lake/getting-started/blob/training_solution/presentation/lecture_notes.md)
  --> We recommend that you follow the presentation and only consult the lecture notes
  in case you need them (the training solutions are posted there...)
- [Data Lakehouse paper](https://www.cidrdb.org/cidr2021/papers/cidr2021_paper17.pdf)
- [SDLB git repository](https://github.com/smart-data-lake/)
- [**H**uman-**O**ptimized **C**onfig **O**bject **N**otation](https://github.com/lightbend/config/blob/main/HOCON.md)
- [SDLB Schema Viewer](https://smartdatalake.ch/json-schema-viewer/#viewer-page)
- [Docu: execution phases](https://smartdatalake.ch/docs/reference/executionPhases)
- [Docu: Data Quality](https://smartdatalake.ch/docs/reference/dataQuality)
- [Polynote](http://localhost:8192/notebook/inspectData.ipynb#Cell4)
- [SDLB with Snowflake](https://smartdatalake.ch/blog/sdl-snowpark/)
- [SDLB with Databricks](https://smartdatalake.ch/blog/sdl-databricks/)
- [SDLB Visualizer](https://github.com/smart-data-lake/sdl-visualization)