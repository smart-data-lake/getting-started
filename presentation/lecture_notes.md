
# Smart Data Lake Builder Hands-On Training

## Organization 

Welcome! We are very happy to have you here today! Before starting, there are two organizational points to clear up:

- **Training agenda:** The training is divided into two parts / days. 
	1. The first part of the training focuses on the theoretical concepts of the framework. The goal of this session is to arm you with the necessary knowledge for you to build your own pipelines and prepare for the second session. 
	2. The second part is almost only hands-on: you will be divided into groups and will build a data pipeline. At the end of the session you will present your solution to the group.

- **For ELCA colleagues:** beside the on-site training time, participants are entitled to use additional 8h for:
	- Setup preparation
  	- Self-paced exercises with SDLB
    	+ lecture notes: https://github.com/smart-data-lake/getting-started/blob/training/presentation/lecture_notes.md
  	- Preparation of use case



<!-- 
Tools: In Teams annotation can be used to point to specific aspects in the configs, SchemaViewer,...
-->

<!-- 
- emphasize that this is and interactive course, motivate for questions
- provide lecture afterwards
- long commands should be pasted in the chat
- ask to follow along and try yourself, no intensive development today, but goal to use the framework by yourself

- icebreaker, the largest amount of data sources or tables you worked with in a single project
-->

## Goal
* train loving friend imagine to **replace** short distant flights **with train** rides
* discover/count all flights which
  - starting from a certain airport 
  - flight distance <500km
  - assume destination airport Bern (LSZB) or Frankfurt (EDDF)

![map about flights around Bern](images/flights_BE.png)

* Let's try to abstract this use case... As data engineers, we want to provide elevated data for data scientists and business. **General steps to be followed**:
  - download data
  - combining/filter/transform data in a general manner
  - store processed data, thus it can be utilized for various use cases
  - analyse/compute data for a specific application
  - different data layers 
    - stage layer (raw data)
    - integration layer (cleaning/structuring/prepared data)
    - business transformation layer (ready for data analysts/scientists to run/develop their applications)

![data layer structure for the use case](images/dataLayers.png)

The Smart Data Lake Builder (SDLB) is the tool we will use to accomplish these steps. Let us take a step back for the moment. We will come back to our use-case in a couple of minutes.

## Smart Data Lake vs. Smart Data Lake Builder

| Smart Data Lake                       | Smart Data Lake Builder                                                       |
|--------------------------------------------------------------|-------------------------------------------------------------------------------|
| **Concept**                                                  | **Tool**                                                                      |
| combines advantages of Data Warehouse and Data Lakes         | ELCA's tool to build Data Pipelines efficiently                               |
| structured data / schema evolution                           | portable and automated                                                        |
| layer (here stg/int/btl) approach / processes / technologies | features like historization, incremental load, partition wise                 |
| Similar to Lakehouse (for more details see [this paper](https://www.cidrdb.org/cidr2021/papers/cidr2021_paper17.pdf)) | Open Source on Github: [smart-data-lake](https://github.com/smart-data-lake/) |

### Why Smart Data Lake Builder (SDLB)?
* defining dataObjets and relation instead of dependency in whole tree -> well suited for complex data pipelines
* **No Code** for standard dataObjects and tasks (historize, de-duplication, column name standardization)
* loading modes out of the box (incremental, partition-wise, streaming, checkpoint/recovery)
* Designed to add custom dataObjects, connectors, and transformers
* DevOps ready: version-able configuration, support for automated testing
* early validation
* portable -> on any platform with java env., even across platforms

## Setup
* clone repo
  ```
  git clone -b training https://github.com/smart-data-lake/getting-started.git SDLB_training
  ```
  OR update:
  ```
  git pull
  git checkout training
  ```

## SDLB general aspects
<!--
  during building lets have a closer look to SDLB
-->
* [https://github.com/smart-data-lake](https://github.com/smart-data-lake)
* Scala project, build with Maven
* with different modules: beside the core we have modules for different platforms, formats and other features
* GPL-3 license 

* we build SDLB core package with additional custom packages. Here we have 2 additional files (Scala classes) with *custom web downloader* and *transformer*
* reuse of artifacts from mounted directory in mvn container


## Hocon - Pipeline Description
* [**H**uman-**O**ptimized **C**onfig **O**bject **N**otation](https://github.com/lightbend/config/blob/main/HOCON.md)
* originating from JSON

Let's start writing a config
> open new file `test_config.conf` <br>
> what to write? -> Schema viewer

### Schema Viewer - What is supported?
> open [SDLB Schema Viewer](https://smartdatalake.ch/json-schema-viewer/#viewer-page)
* distinguish `global`, `dataObjects`, `actions`, and `connections`

> write sections `dataObjects { }` and `actions { }` in our new config file.

### DataObjects
There are data objects different types: files, database connections, and table formats.
To mention **a few** dataObjects:

* `JdbcTableDataObject` to connect to a database e.g. MS SQL or Oracle SQL
* `KafkaTopicDataObject` to read from Kafka Topics
* `DeltaLakeTableDataObject` tables in delta format (based on parquet), including schema registered in metastore and transaction logs enables time travel (a common destination)
* `SnowflakeTableDataObject` access to Snowflake tables
* `AirbyteDataObject` provides access to a growing list of [Airbyte](https://docs.airbyte.com/integrations/) connectors to various sources and sinks e.g. Facebook, Google {Ads,Analytics,Search,Sheets,...}, Greenhouse, Instagram, Jira,...

### Actions
SDLB is designed to define/customize your own actions. Nevertheless, there are basic/common actions implemented and a general framework provided to implement your own specification

* ``FileTransferAction``: pure file transfer
* ``CopyAction``: basic generic action. Reads source into DataFrame and then writes DataFrame to target data object. Provides opportunity to add **transformer(s)**
* ``CostumDataFrameAction``: can handle **multiple inputs/outputs**
* ...
* actions with additional logic, e.g.
  - ``DeduplicateAction``: verifies to not have duplicates between input and output, keeps last record and history when *captured*
  - ``HistorizeAction``: technical historization using **valid-from/to** columns

#### Transformations
* distinguish between **1to1** (CopyAction, Dedup/Hist) and **many-to-many** (CustomDataFrame) transformations
* transformers supports languages:
  - ScalaClass
  - ScalaCode
  - SQL
  - Python
* transformers with additional logic, e.g.:
  - `StandardizeColNamesTransformer`
  - `AdditionalColumnsTransformer` (in HistorizeAction), adding information from context or derived from input, for example, adding input file name
  - `SparkRepartitionTransformer` for optimized file handling

What we have here:
* in `config/airports.conf` we already saw an SQL transformer
* in `config/departures.conf` look at `download-deduplicate-departures`
  - **chained** transformers
  - first **SQL** query, to convert UnixTime to dateTime format
  - then **Scala Code** for deduplication
    + the deduplication action does compare input and target
    + the transformation verifies that there are no duplicated in the input
* in `config/distances.conf` a Scala class is called
  - see `src/main/scala/com/sample/ComputeDistanceTransformer.scala`
    + definition and usage of distance calculation

> Note: *transformer* is deprecated

### config Structure

Let's have a look to the present implementation:

> **WSL**: `ls config ; ls envConfig` 
> <br>
> **IntelliJ**: show directory structure especially `config` -> see multiple configuration files

* specification of the pipeline can be split in **multiple files** and even **directories**
  - -> directories can be used to manage different environments e.g. 

```
config
+-- global.conf
+-- sourceA.conf
+-- sourceB.conf
+-- app1.conf
envConfig
+-- local.conf
+-- awsDev.conf
+-- azureDev.conf
```

Let's have a look into a configuration file:
> `config/airports.conf` 
> <br>
> Note: you can also use other viewer/editor, e.g. vim in Ubuntu or SublimeText or IntelliJ in Windows using `\\wsl$\Ubuntu\home\<username>\...`

* 3 **data objects** for 3 different layers: **ext**, **stg**, **int**
  - here each data object has a different type: WebserviceFileDataObject, CsvFileDataObject, DeltaLakeTableDataObject
  - `ext_airports`: specifies the location of a file to be downloaded 
  - `stg_airports`: a staging CSV file to be downloaded into (raw data)
  - `int_airports`: filtered and written into `DeltaLakeTable`

* 2 **actions** defining the connection between the data objects
  - first simple download
  - then filter and historize

* structures and parameters, like *type*, *inputId*,...
* **Transformer** will be handled later

<!--
## Excursion: env variables
- usage of optional env variables
  ```Hocon
  basedir = "/whatever/whatever"
  basedir = ${?FORCED_BASEDIR}
  ```
- overwrite parameters with env variables
  + specify java option `-Dconfig.override_with_env_vars=true` in Docker entrypoint and
  + env var:
    * prefix `CONFIG_FORCE_` is stripped
    * single underscore(`_`) is converted into a dot(`.`)
    * double underscore(`__`) is converted into a dash(`-`)
    * triple underscore(`___`) is converted into a single underscore(`_`)
:warning: TODO overwrite not working'
-->

## Feeds
* start application with `--help`: 
> * **WSL**: `podman run --rm --pod sdlb_training sdl-spark --help`
>   * Note: `--rm` removes container after execution, `--pod` specifies the pod to run in, with supporting containers
> * **IntelliJ**: configure Run with parameters `--help`
> Note: configure: Java 11?, main class `io.smartdatalake.app.LocalSmartDataLakeBuilder`


* `feed-sel` always necessary 
	- can be specified by metadata feed, name, or ids
	- can be lists or regex, e.g. `--feed-sel '.*airport.*'` **Note**: on CLI we need `'.*'` in IntelliJ we can directly use `.*`
	- can also be `startWith...` or `endWith...`

* directories for mounting data, target and config directory, container name, config directories/files

* try run feed everything: 
> * **WSL**: `podman run --rm --hostname=localhost --pod sdlb_training -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config -v ${PWD}/envConfig:/mnt/envConfig sdl-spark:latest --config /mnt/config,/mnt/envConfig/local_WSL.conf --feed-sel '.*airport.*'`
>  - Note: data, target, config, and envConfig directories are mounted into the container
> * **IntelliJ**: 
> work to where we want to be, start with `--feed-sel .*airport.* --test config`
> run parameters: `-c $ProjectFileDir$/config,$ProjectFileDir$/envConfig/local_Intellij.conf --feed-sel .*airport.*`

## Environment Variables in HOCON

Note error: 
* **WSL** error: `Could not resolve substitution to a value: ${METASTOREPW}`
* **IntelliJ** error: `Could not resolve substitution to a value: ${DATALAKEPREFIX}`

Task: What is the issue? -> fix issue 
<!-- A collapsible section with markdown -->
> <details><summary>Solution: Click to expand!</summary>
> WSL: in `envConfig/local_WSL.conf` we defined `"spark.hadoop.javax.jdo.option.ConnectionPassword" = ${METASTOREPW}` <br>
> the Metastore password is set while configuring the metastore. 
> In the Metastore Dockerfile the `metastore/entrypoint.sh` is specified. 
> In this file the Password is specified as 1234.
> Thus, set environment variable in the container using the podman option: `-e METASTOREPW=1234` <br>
> Note: better not to use clear test passwords anywhere. 
> In cloud environment use password stores and its handling. 
> Avoid passwords being exposed in repos and logs. 
> <br>
> IntelliJ: In the env config file the variable DATALAKEPREFIX is used to control the location of data.
> Here, setting an environment variable DATALAKEPREFIX is necessary. Let's go with `data`
> </details>

> **WSL**
> define an alias thus we do not specify the core arguments again and again and it gets more clear:
> - Let's define a command: <br>
>   `alias sdlb_cmd="podman run --rm --hostname=localhost --pod sdlb_training -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config -v ${PWD}/envConfig:/mnt/envConfig sdl-spark:latest --config /mnt/config,/mnt/envConfig/local_WSL.conf"`


## Test Configuration
since we realize there could be issues, let's first run a config test using `--test config`:

> * **WSL**: `sdlb_cmd --feed-sel '.*airport.*' --test config` (fix bug together)
> * **IntelliJ**: add `--test config`, thus we set: `-c $ProjectFileDir$/config,$ProjectFileDir$/envConfig/local_Intellij.conf --feed-sel .*airport.* --test config`

* while running we get:
`Exception in thread "main" io.smartdatalake.config.ConfigurationException: (DataObject~stg_airports) ClassNotFoundException: Implementation CsvFoobarDataObject of interface DataObject not found`
let us double-check what DataObjects there are available... [SDLB Schema Viewer](http://smartdatalake.ch/json-schema-viewer/index.html#viewer-page&version=sdl-schema-2.3.0-SNAPSHOT.json)

Task: fix issue 
<!-- A collapsible section with markdown -->
> <details><summary>Solution: Click to expand!</summary>
> In `config/airports.conf` correct the data object type of stg_airports to *CvsFileDataObject*
> </details>

## Dry-run
* run again (and then with) `--test dry-run` and feed `'.*'` to check all configs: 

> * **WSL**:  `sdlb_cmd --feed-sel '.*airport.*' --test dry-run`
> * **IntelliJ**: add `--test dry-run`, thus we set: `-c $ProjectFileDir$/config,$ProjectFileDir$/envConfig/local_Intellij.conf --feed-sel .*airport.* --test dry-run`

## DAG
* (Directed acyclic graph)
> show DAG in output
* automatically created using the specifications in the SDLB config. 
* can fork and join
* no recursion

```
                        ┌─────┐          
                        │start│
                        └─┬─┬─┘
                          │ │
                          │ └─────────┐
                          v           │
           ┌─────────────────┐        │
           │download-airports│        │
           └────────┬────────┘        │
                    │                 │
           ┌────────┘                 │
           │                          │
           v                          v
 ┌──────────────────┐ ┌───────────────────────────────┐
 │historize-airports│ │download-deduplicate-departures│
 └─────────┬────────┘ └────────┬──────────────────────┘
           │                   │
           └───────────┐       │
                       │       │
                       v       v
              ┌────────────────────────┐
              │join-departures-airports│
              └────────────┬───────────┘
                           │
                           v
                  ┌─────────────────┐
                  │compute-distances│
                  └─────────────────┘
```

## Execution Phases
let's run without `dry-run`
> * **WSL**: real execution: `sdlb_cmd --feed-sel 'airport'`
> * **IntelliJ**: `-c $ProjectFileDir$/config,$ProjectFileDir$/envConfig/local_Intellij.conf --feed-sel .*airport.*`

* logs reveal the **execution phases**
* in general, we have: 
    - configuration parsing
    - DAG preparation
    - DAG init
    - DAG exec (not processed in dry-run mode)
* early validation: in init even custom transformation are checked, e.g. identifying mistakes in column names
* [Docu: execution phases](https://smartdatalake.ch/docs/reference/executionPhases)

## Inspect result
* files in the file system: `stg_airport`: CSV files located at `data/stg_airports/`

> * **WSL**: Polynote: tables in the DataLake
>  - open [Polynote at localhost:8192](http://localhost:8192/notebook/inspectData.ipynb)
> * **IntelliJ**: open Avro/Parquet Viewer and Drag and drop file into 

> <details><summary>Example content</summary>
> ```
> $ head data/stg_airports/result.csv
> "id","ident","type","name","latitude_deg","longitude_deg","elevation_ft","continent","iso_country","iso_region","municipality","scheduled_service","gps_code","iata_code","local_code","home_link","wikipedia_link","keywords"
> : 6523,"00A","heliport","Total Rf Heliport",40.07080078125,-74.93360137939453,11,"NA","US","US-PA","Bensalem","no","00A",,"00A",,,
> 323361,"00AA","small_airport","Aero B Ranch Airport",38.704022,-101.473911,3435,"NA","US","US-KS","Leoti","no","00AA",,"00AA",,,
> 6524,"00AK","small_airport","Lowell Field",59.947733,-151.692524,450,"NA","US","US-AK","Anchor Point","no","00AK",,"00AK",,,
> 6525,"00AL","small_airport","Epps Airpark",34.86479949951172,-86.77030181884766,820,"NA","US","US-AL","Harvest","no","00AL",,"00AL",,,
> 6526,"00AR","closed","Newport Hospital & Clinic Heliport",35.6087,-91.254898,237,"NA","US","US-AR","Newport","no",,,,,,"00AR"
> 322127,"00AS","small_airport","Fulton Airport",34.9428028,-97.8180194,1100,"NA","US","US-OK","Alex","no","00AS",,"00AS",,,
> 6527,"00AZ","small_airport","Cordes Airport",34.305599212646484,-112.16500091552734,3810,"NA","US","US-AZ","Cordes","no","00AZ",,"00AZ",,,
> 6528,"00CA","small_airport","Goldstone (GTS) Airport",35.35474,-116.885329,3038,"NA","US","US-CA","Barstow","no","00CA",,"00CA",,,
> 324424,"00CL","small_airport","Williams Ag Airport",39.427188,-121.763427,87,"NA","US","US-CA","Biggs","no","00CL",,"00CL",,,
> ```
> </details>
  
now we have tested and executed the part for airport, let's go for the whole pipeline. First we start with the testing again.

## Schema handling
* test the whole pipeline using `.*` and `--test dry-run`
> * **WSL**: `sdlb_cmd --feed-sel '.*'  --test dry-run `
> * **IntelliJ**: `-c $ProjectFileDir$/config,$ProjectFileDir$/envConfig/local_Intellij.conf --feed-sel .* --test dry-run`
* execution fail in init phase by because of not finding "foobar" column in `download-deduplicate-departures`:

```
2022-08-05 07:51:14 INFO  ActionDAGRun$ - Init FAILED for sdlb_training :
                       ┌─────┐
                       │start│
                       └──┬┬─┘
                          ││
                          │└─────────────────────────┐
                          v                          │
 ┌─────────────────────────────────────────────────┐ │
 │download-deduplicate-departures FAILED PT0.31359S│ │
 └───────────────────┬─────────────────────────────┘ │
                     │           ┌───────────────────┘
                     │           │
                     v           v
         ┌──────────────────────────────────┐
         │join-departures-airports CANCELLED│
         └────────────────┬─────────────────┘
                          │
                          v
            ┌───────────────────────────┐
            │compute-distances CANCELLED│
            └───────────────────────────┘
     [main]
Exception in thread "main" io.smartdatalake.util.dag.TaskFailedException: 
    Task download-deduplicate-departures failed. 
    Root cause is 'AnalysisException: cannot resolve 'foobar' given input columns: 
        [ext_departures_sdltemp.arrivalAirportCandidatesCount, ext_departures_sdltemp.callsign, 
        ext_departures_sdltemp.created_at, ext_departures_sdltemp.departureAirportCandidatesCount, 
        ext_departures_sdltemp.estArrivalAirport, ext_departures_sdltemp.estArrivalAirportHorizDistance, 
        ext_departures_sdltemp.estArrivalAirportVertDistance, ext_departures_sdltemp.estDepartureAirport, 
        ext_departures_sdltemp.estDepartureAirportHorizDistance, ext_departures_sdltemp.estDepartureAirportVertDistance, 
        ext_departures_sdltemp.firstSeen, ext_departures_sdltemp.icao24, ext_departures_sdltemp.lastSeen]; 
        line 1 pos 7;'
```

* SDLB does schema validation, creates Schemata for all spark supported data objects: user defined or inference
    - support for schema evolution 
      + replaced or extended or extend (new column added, removed columns kept) schema 
		+ for JDBC and DeltaLakeTable, need to be enabled

Task: fix issue 
<!-- A collapsible section with markdown -->
> <details><summary>Solution: Click to expand!</summary>
> In `config/departures.conf` correct the data object download-deduplicate-departures to not select foobar
> </details>


* run whole pipeline with `.*` and without ~~`--test dry-run`~~  
> * **WSL**: `sdlb_cmd --feed-sel '.*' `
> * **IntelliJ**: `-c $ProjectFileDir$/config,$ProjectFileDir$/envConfig/local_Intellij.conf --feed-sel .*`

* show results
    after the listing tables and schema, we monitor the amount of data in the tables and the latest value
> * **WSL**: `departure table consists of 457 row and entries are of original date: 20210829 20210830`
> * **IntelliJ**: 224+233 rows in 2 parquet files and `dt` dates of `20210829` and `20210830`

## Unit Tests
not only during runtime we want to have our code tested. When we develop new dataObjects, transformers etc., 
we want to have them tested during compile time. An example where a unit test is created using synthetic data and a related config file:  

runSimulation -> unit with synthetical DataFrames
[Unit Test in SDLB](https://github.com/smart-data-lake/smart-data-lake/blob/develop-spark3/sdl-core/src/test/scala/io/smartdatalake/workflow/action/ScalaClassSparkDsNTo1TransformerTest.scala#L325)
and
[Corresponding Config File](https://github.com/smart-data-lake/smart-data-lake/blob/develop-spark3/sdl-core/src/test/resources/configScalaClassSparkDsNto1Transformer/usingDataObjectIdWithPartitionAutoSelect.conf)

<! probably change presenters here>


## Partitions
First have a look at `data/btl_distances`.

There are two subdirectories named with the partition name and value.

**Task**: recompute *compute-distances* only with/for partition `LSZB` <br>
**Hint**: use CLI help

><details><summary>Solution: Click to expand!</summary>
> to specify a partion, the CLI option `--partition-value` need to be used. 
> Here we need `--partition-values estdepartureairport=LSZB`
> Execute <br>
> * **WSL**: `sdlb_cmd --feed-sel ids:compute-distances --partition-values estdepartureairport=LSZB`
> * **IntelliJ**: `-c $ProjectFileDir$/config,$ProjectFileDir$/envConfig/local_Intellij.conf --feed-sel ids:compute-distances --partition-values estdepartureairport=LSZB`
></details>

When you now look at data/btl_distances, you will only see an updated partition estdepartureairport=LSZB 
and in the logs you find: `start writing to DataObject~btl_distances, partitionValues estdepartureairport=LSZB [exec-compute-distances]`)

Working with partitions forces to create the whole data pipeline around them <br> 
-> **everything needs to be partitioned** by that key. <br>
The trend goes towards incremental processing (see next chapter).
But batch processing with partitioning is still the most performant data processing method 
when dealing with large amounts of data.

## Incremental Load
* desire to **not read all** data from input at every run -> incrementally
* or **here**: departure source **restricted request** to <7 days
  - initial request 2 days 29.-20.08.2021

### General aspects
* in general, we often want an initial load and then regular updates
* distinguish between
* **StateIncremental** 
  - stores a state, utilized during request submission, e.g. WebService or DB request
* **SparkIncremental**
  - uses max values from **compareCol**
  - *DataFrameIncrementalMode* and *FileIncrementalMode*
 
### Current Example
Let's try out StateIncremental with the action `download-deduplicate-departures`
* state is used to store last position
  - To be able to use the StateIncremental mode [CustomWebserviceDataObject](https://github.com/smart-data-lake/getting-started/blob/training/src/main/scala/io/smartdatalake/workflow/dataobject/CustomWebserviceDataObject.scala) needs to: 
    + Implement Interface `CanCreateIncrementalOutput` and defining the `setState` and `getState` methods
    + instantiating state variables 
    + see also [getting-started example](https://smartdatalake.ch/docs/getting-started/part-3/incremental-mode)

These Requirements are already met.

* To enable stateIncremental we need to change the action `download-deduplicate-departures` and set these parameters of the DeduplicateAction:
  ```
    executionMode = { type = DataObjectStateIncrementalMode }
    mergeModeEnable = true
    updateCapturedColumnOnlyWhenChanged = true
  ```

After changing our config, try to execute the concerned action
> * **WSL**: `sdlb_cmd --feed-sel ids:download-deduplicate-departures`
> * **IntelliJ**: `-c $ProjectFileDir$/config,$ProjectFileDir$/envConfig/local_Intellij.conf --feed-sel ids:download-deduplicate-departures`

Now it will **fail** because we need to provide a path for the state-path. 

Add state path and name:
> * **WSL**: `sdlb_cmd --feed-sel ids:download-deduplicate-departures --state-path /mnt/data/state -n SDLB_training`
> * **IntelliJ**: `-c $ProjectFileDir$/config,$ProjectFileDir$/envConfig/local_Intellij.conf --feed-sel ids:download-deduplicate-departures --state-path $ProjectFileDir$/data/state -n SDLB_training`


* **first run** creates `data/state/succeeded/SDLB_training.1.1.json` 
  - see line `"state" : "[{\"airport\":\"LSZB\",\"nextBegin\":1630310979},{\"airport\":\"EDDF\",\"nextBegin\":1630310979}]"`
    + > other content will be regarded later
  - this is used for the next request
* see next request in output of **next run**:
  `CustomWebserviceDataObject - Success for request https://opensky-network.org/api/flights/departure?airport=LSZB&begin=1631002179&end=1631347779 [exec-download-deduplicate-departures]`
> run a couple of times
  - check the increasing amount of lines collected in table
>* **WSL**: [Polynote](http://localhost:8192/notebook/inspectData.ipynb#Cell4)
>* **IntelliJ**: Parquet Viewer

> Note: When get result/error: `Webservice Request failed with error <404>`, if there are no new data available. 

## Streaming
* continuous processing, cases we want to run the actions again and again

### Command Line
* command line option `-s` or `--streaming`, streaming all selected actions
  - requires `--state-path` to be set
> * **WSL**: `sdlb_cmd  --feed-sel ids:download-deduplicate-departures --state-path /mnt/data/state -n SDLB_training -s` 
> * **IntelliJ**: `-c $ProjectFileDir$/config,$ProjectFileDir$/envConfig/local_Intellij.conf --feed-sel ids:download-deduplicate-departures --state-path $ProjectFileDir$/data/state -n SDLB_training -s`
* and see the action running again and again

-> notice the recurring of the action
-> monitor the growth of the table
-> possible see streaming trigger interval of 48s in output: `LocalSmartDataLakeBuilder$ - sleeping 48 seconds for synchronous streaming trigger interval [main]` otherwise process took more than 60 sec  

Task: change the streaming trigger interval to 10s (or alternatively to 120s)
Hint: search for streaming in [Schema Viewer](https://smartdatalake.ch/json-schema-viewer/)

> <details><summary>Solution: Click to expand!</summary>
> search stream in Schema Viewer 
> and add to the `config/global.conf` -> `global`->`synchronousStreamingTriggerIntervalSec = 10` 
> This defines the interval between 2 starts (not end to start)
> </details>
 
  * Now output looks like this :
    ```
      2022-08-04 10:56:28 INFO  ActionDAGRun$ActionEventListener - Action~download-deduplicate-departures[DeduplicateAction]: Exec succeeded [dag-24-651]
      2022-08-04 10:56:28 INFO  HadoopFileActionDAGRunStateStore - updated state into file:/mnt/data/state/current/SDLB_training.24.1.json [dag-24-651]
      2022-08-04 10:56:28 INFO  ActionDAGRun$ - exec SUCCEEDED for dag 24:
      ┌─────┐
      │start│
      └───┬─┘
      │
      v
      ┌─────────────────────────────────────────────────────┐
      │download-deduplicate-departures SUCCEEDED PT4.829176S│
      └─────────────────────────────────────────────────────┘
      [main]
      2022-08-04 10:56:28 INFO  HadoopFileActionDAGRunStateStore - updated state into file:/mnt/data/state/succeeded/SDLB_training.24.1.json [main]
      2022-08-04 10:56:28 INFO  LocalSmartDataLakeBuilder$ - sleeping 5 seconds for synchronous streaming trigger interval [main]
    ```

## Execution Modes
for Actions there are different execution modes, including various incremental modes, e.g.:
  * `SparkStreamingMode`
    - single action streaming
      + action -> executionMode -> SparkStreamingMode
  * see other execution modes ... explore Schema Viewer and explore the SDL code 
    - PartitionDiffMode, FailNoPartitionValuesMode, ...

## Parallelism
Distinguish 2 types of parallelism:
  - within a spark job: the amount of Spark tasks, controlled by global option `    "spark.sql.shuffle.partitions" = 2`
  - parallel running DAG actions of SDLB, by default serial, one by one action
    + see `Action~download-airports[FileTransferAction]: Exec started` and `Action~download-deduplicate-departures[DeduplicateAction]`
    + use command line option `--parallelism 2` to run both tasks in parallel. compare:

First, measure serial run: 
> * **WSL**: `sdlb_cmd --feed-sel .* --state-path /mnt/data/state -n SDLB_training >& out.serial`
> * **IntelliJ**: 
>   * CLI arguments `-c $ProjectFileDir$/config,$ProjectFileDir$/envConfig/local_Intellij.conf --feed-sel .* --state-path $ProjectFileDir$/data/state -n SDLB_training`
>   * Save console output file: `$ProjectFileDir$\out.serial`

Then run in parallel: adding `--parallelism 2` and change output file name
> * **WSL**: `sdlb_cmd --feed-sel .* --state-path /mnt/data/state -n SDLB_training --parallelism 2 >& out.parallel`
> * **IntelliJ**:
    >   * CLI arguments `-c $ProjectFileDir$/config,$ProjectFileDir$/envConfig/local_Intellij.conf --feed-sel .* --state-path $ProjectFileDir$/data/state -n SDLB_training --parallelism 2`
>   * Save console output file: `$ProjectFileDir$\out.prarallel`

* Without parallelsim (out.serial): Action2 starts only after Action1 is finished
  ```    
       2022-08-04 12:24:18 INFO  ActionDAGRun$ActionEventListener - Action~download-airports[FileTransferAction]: Exec started [dag-30-109]
       2022-08-04 12:24:18 INFO  FileTransferAction - (Action~download-airports) start writing to DataObject~stg_airports [exec-download-airports]
       2022-08-04 12:24:18 INFO  CsvFileDataObject - (DataObject~stg_airports) deleteAll stg_airports [exec-download-airports]
       2022-08-04 12:24:18 INFO  StreamFileTransfer - Copy DataObject~ext_airports:result -> DataObject~stg_airports:stg_airports/result.csv [exec-download-airports]
       2022-08-04 12:24:19 INFO  FileTransferAction - (Action~download-airports) finished writing DataFrame to stg_airports: jobDuration=PT0.984S files_written=1 [exec-download-airports]
       2022-08-04 12:24:19 INFO  ActionDAGRun$ActionEventListener - Action~download-airports[FileTransferAction]: Exec succeeded [dag-30-109]
       2022-08-04 12:24:19 INFO  HadoopFileActionDAGRunStateStore - updated state into file:/mnt/data/state/current/SDLB_training.30.1.json [dag-30-109]
       2022-08-04 12:24:19 INFO  ActionDAGRun$ActionEventListener - Action~download-deduplicate-departures[DeduplicateAction]: Exec started [dag-30-109]
       2022-08-04 12:24:19 INFO  DeduplicateAction - (Action~download-deduplicate-departures) getting DataFrame for DataObject~ext_departures [exec-download-deduplicate-departures]
  ```

* With parallelsim (out.parallel): Action2 starts while Action1 is still running
  ```    
       2022-08-04 12:23:08 INFO  ActionDAGRun$ActionEventListener - Action~download-airports[FileTransferAction]: Exec started [dag-29-93]
       2022-08-04 12:23:08 INFO  ActionDAGRun$ActionEventListener - Action~download-deduplicate-departures[DeduplicateAction]: Exec started [dag-29-94]
       2022-08-04 12:23:08 INFO  DeduplicateAction - (Action~download-deduplicate-departures) getting DataFrame for DataObject~ext_departures [exec-download-deduplicate-departures]
       2022-08-04 12:23:08 INFO  FileTransferAction - (Action~download-airports) start writing to DataObject~stg_airports [exec-download-airports]
       2022-08-04 12:23:08 INFO  CsvFileDataObject - (DataObject~stg_airports) deleteAll stg_airports [exec-download-airports]
       2022-08-04 12:23:08 INFO  StreamFileTransfer - Copy DataObject~ext_airports:result -> DataObject~stg_airports:stg_airports/result.csv [exec-download-airports]
       2022-08-04 12:23:09 INFO  CustomWebserviceDataObject - Success for request https://opensky-network.org/api/flights/departure?airport=LSZB&begin=1630310979&end=1630656579 [exec-download-deduplicate-departures]
       2022-08-04 12:23:09 INFO  FileTransferAction - (Action~download-airports) finished writing DataFrame to stg_airports: jobDuration=PT1.699S files_written=1 [exec-download-airports]
       2022-08-04 12:23:09 INFO  ActionDAGRun$ActionEventListener - Action~download-airports[FileTransferAction]: Exec succeeded [dag-29-93]
       2022-08-04 12:23:09 INFO  HadoopFileActionDAGRunStateStore - updated state into file:/mnt/data/state/current/SDLB_training.29.1.json [dag-29-93]
  ```
- :warning: parallel actions are more difficult to **debug**

## Checkpoint / Restart
When the run crashes we want to restart from where we left and only run remaining tasks. Especially when handling large datasets.
* requires states (`--state-path`)

Let's try.
> Since we use states already, just run again (**serial**, no log file necessary) and cancel inbetween
> * **WSL**: `sdlb_cmd --feed-sel .* --state-path /mnt/data/state -n SDLB_training`
> * **IntelliJ**: CLI arguments `-c $ProjectFileDir$/config,$ProjectFileDir$/envConfig/local_Intellij.conf --feed-sel .* --state-path $ProjectFileDir$/data/state -n SDLB_training`

-> cancel run to simulate crash (**after download** phase when seeing in the logs):
```
(Action~download-airports) finished writing DataFrame to stg_airports: jobDuration=PT0.871S files_written=1 [exec-download-airports]
...
ActionDAGRun$ActionEventListener - Action~download-deduplicate-departures[DeduplicateAction]: Exec succeeded [dag-1-191]
```

* inspect **current** state in file: `data/state/current/SDLB_training.?.?.json`
  - see the SUCCESS and CANCELED statements
* restart with the same command
  - notice line at the beginning: `LocalSmartDataLakeBuilder$ - recovering application SDLB_training runId=1 lastAttemptId=1 [main]`
  - notice the changed DAG, no download

## Execution Engines vs Execution Environments
[Go through documentation](https://smartdatalake.ch/docs/reference/executionEngines)
> Look at plot at bottom and explain when which Engine is running (see also table on top): 
> When copying Files, when copying Data from a File to a Spark Table,
> When Transforming Data with Snowflake via Snowpark
> When Transforming Data between Spark and Snowflake

If you are interested in trying out SDLB with Snowflake, you can follow this [Blog Post](https://smartdatalake.ch/blog/sdl-snowpark/)

## SDL Viewer
There is a new **extension** of SDLB which visualize the configuration and its documentation. 
This acts as a **data catalog** and presents beside the dependencies (DAG) **all metadata information** of dataObject and Actions. 
The viewer runs separately 

> * **WSL**: in a container,and can be launched browsing to [localhost:5000](http://localhost:5000).
> Note: there is still an issue with parsing "unresolved" variables. If you see just "Loading", 
> uncomment out the `$METASTOREPW` or `DATALAKEPREFIX` in `envConfig/local*.conf`.

# Exercise
> **Task**: create a new table provided in CSV format:
> * airports name
> * elevation in ft
> * and elevation in m 

> <details><summary>Solution: Click to expand!</summary>
> 
> * create a dataObject like
> ```
>  btl_airports_elevation { ### TODO remove for training
>    type = CsvFileDataObject
>    path = ${env.datalakeprefix}"/~{id}"
>    metadata {
>      name = "Calculated Airport elevation in meters"
>      description = "contains beside GPS coordiantes, elevation, continent, country, region"
>      layer = "staging"
>      subjectArea = "airports"
>      tags = ["aviation", "airport", "location"]
>    }
>  }
> ```
> * create an action using stg_airports as input and the above dataObject as output
> * e.g. with `SQLDfTransformer`: `code = "select name, elevation_ft, (elevation_ft / 3.281) as elevation_meters from stg_airports"`
> ```
> export-airport-elevations { ### TODO remove for training
>   type = CopyAction
>   inputId = stg_airports
>   outputId = btl_airports_elevation
>   transformers = [{
>     type = SQLDfTransformer
>     code = "select name, elevation_ft, (elevation_ft / 3.281) as elevation_meters from stg_airports" #Tricky, do not use comma but decimal point ;-)
>   }]
>   metadata {
>     name = "Airport elevation"
>     description = "Write airport elevation in meters to Parquet file"
>     feed = download-airport
>   }
>  }
> ```
> </details>

# SDLB feature summary
* [ ] Run **anywhere**
* [ ] Integrations for major public **clouds** (as jar in Databricks, AWS Glue; container e.g. in Kubernetes; in VM)
* [ ] Support for different **Execution Engines** (Files, Spark, Snowflake for now)
* [ ] **Open-source**
* [ ] **easily-extendable** (Scala & Python)
* [ ] **reusable** generic transformations (SQL, Python, Scala)
* [ ] Automated, optimized **DAG** execution
* [ ] **Batch** and near-realtime **Streaming**
* [ ] **Automation Tool** with declarative, reusable configuration approach
* [ ] **Early Validation** of configuration and data pipeline schema problems
* [ ] **Large Connectivity**: Spark connectors (incl. Iceberg & Deltalake), Kafka, Files, SFTP, Webservice + Airbyte Connectors
* [ ] **Data Quality** checks, expectations & metrics integrated
* [ ] Support for Unit/Integration/Smoke **Testing**
* [ ] Integrated **MLOps** with MFLow (train & predict)
* [ ] Monitoring: metrics in logs, e.g. size of written DataFrame
* [ ] Constrains: specify limitations, error/warning when exceeding
* [ ] Expectations: notifications if diverging from specified expectation, e.g. number of partitions
* [ ] Housekeeping: 
  * PartitionRetentionMode:  Keep partitions while retention condition is fulfilled, delete other partitions
  * PartitionArchiveCompactionMode: Archive and compact old partitions -> Is now already covered by Deltalake
* [ ] Spark Specific Features: BreakDataFrameLineage and Autocaching

## RoadMap
Q1:
* Catalog support in Notebook (Scala)
* Integrated MLOps with MFLow (train & predict)
* Remote Agent support (Preview)
  Q2
* Extended Metrics Collection for Iceberg and Delta Lake
* Operations UI for visualizing Runtime Information
  H2:
* Language Server: Code completion for configuration files in Visual Studio Code and IntelliJ

2024:
* SaaS User Interface / Rebranding?

-----
# References
* SDLB source [github.com/smart-data-lake/smart-data-lake](https://github.com/smart-data-lake/smart-data-lake)
* Documentation [smartdatalake.ch/docs](https://smartdatalake.ch/docs/)
* Schema Viewer [smartdatalake.ch/json-schema-viewer/](https://smartdatalake.ch/json-schema-viewer/)
* getting started [github.com/smart-data-lake/getting-started](https://github.com/smart-data-lake/getting-started)

-----
# Homework
* split into groups of 2 or **3**
* find use case you implement next week in a 4h session
  - input: data sources (webservice or file or (local) database)
  - output: targets (simplest: CSV, or DeltaLake, or other)
  - multiple dataObjects and actions
  - suggestion: at least one transformation (more than data copy)
  - sketch dataObjects and actions with main properties/operations
  - see https://smartdatalake.ch/JsonSchemaViewer/ for inspiration

* next week:
  - first present and discuss ideas and analyze feasibility, methods to implement
  - you work together on the implementation and SDLB experts will assist you

------

# Additional Topics

### BreakDataFrameLineage and Autocaching
* By default, spark creates a plan of operations and process them if the target element needs to be realized
  - computation is performed again even if the data is written to a dataObject (file, or table,...)
* Spark provides an option called *cache* to keep the created data in memory
* SDLB uses this option by default for all defined dataObjects, thus during the execution of a pipeline each dataFrame is computed only once, even when used multiple times

Let's consider the scenario illustrated in this figure:
![Data linage from JDBC to DeltaLake table to CSV file](images/lineageExample.png)
 
Assuming an implementation in Spark, e.g. in our Notebook, the code would look like:

```
  val dataFrame2 = spark.table("table1").transform( <doSomeComplexStuff1> )
  dataFrame2.write.saveAsTable("table2")
  val dataFrame3 = dataFrame2.transform( <doSomeComplexStuff2> )
  dataFrame3.write.format("csv").save("/path/of/csv") // computing starting from table1
  
  dataFrame3.show() // Restarts computation from table1
  dataFrame3.show() // Restarts computation from table1
```

Implementing this pipeline in SDLB would look as config:
 
```
dataObjects {
  object1 {
    type = JdbcTableDataObject
    path = "~{id}"
    table {
      db = "default"
      name = "table1"
    }
  object2 {
    type = DeltaLakeTableDataObject
    path = "~{id}"
    table {
      db = "default"
      name = "table2"
    }
  object3 {
    type = CsvFileDataObject
    path = "~{id}"
  }
  
actions {
  A1 {
    type = CustomDataFrameAction
    inputId = object1
    outputId = object2
    ... <transformation doSomeComplexStuff1>
  }
    A2 {
    type = CustomDataFrameAction
    inputId = object2
    outputId = object3
    ... <transformation doSomeComplexStuff2>
  }
```

SDLB automatically caches all DataFrames of dataObjects. 
(But not intermediate dataFrames defined in a transformer). 
Thus, Action A2 uses the DataFrame from memory belonging to table3. 
But table 3 does not need to be re-read, nor recomputed from table1. 
In spark, you would write `dataFrame2.cache`.

However, it will still keep the original Spark-Execution DAG, go over it and then realize that some steps are already cached.
When chaining lots of transformations together, Spark's Execution DAG can get very large and this can cause performance issue and weird bugs.
SDLB allows you to break the DAG into smaller pieces with the option `breakDataFrameLineage=true` set on the desired action.
```
    A2 {
    type = CustomDataFrameAction
    inputId = object2
    outputId = object3
    breakDataFrameLineage=true
    ...
  }
````
With the above config, SDLB will always read from whatever was written in table2 (object2) without considering results that were cached in-memory.
[This is an example of what a typical DAG in Spark may look like](https://stackoverflow.com/questions/41169873/spark-dynamic-dag-is-a-lot-slower-and-different-from-hard-coded-dag)

----
# Databricks
Here we have the Databricks setup already prepared, and briefly present the setup, just to give you an idea.

#### Preparation steps (not part of the demonstration)
For reference see also: [SDL Deployment on Databricks](https://smartdatalake.ch/blog/sdl-databricks/).
The following setup is already prepared in the elca-dev tenant:

* uploading files
  - upload jar
    + first build fat-jar: `podman run -v ${PWD}:/mnt/project -v ${PWD}/.mvnrepo:/mnt/.mvnrepo maven:3.6.0-jdk-11-slim -- mvn -DskipTests  -P fat-jar -f /mnt/project/pom.xml "-Dmaven.repo.local=/mnt/.mvnrepo" package`
    + upload Databricks `Workspace`->`User`->`<Username>`->`Import`-> link in `(To import a library, such as a jar or egg, click here)`
  - create typesafe fix:
    ```BASH
    cat << EOF >> ./config-install.sh
    #!/bin/bash
    wget -O /databricks/jars/-----config-1.4.1.jar https://repo1.maven.org/maven2/com/typesafe/config/1.4.1/config-1.4.1.jar
    EOF
    databricks fs mkdirs dbfs:/databricks/scripts
    databricks fs cp ./config-install.sh dbfs:/databricks/scripts/
    ```
  - create compute resource:
    + use the uploaded jar
    + use init script: `dbfs:/databricks/scripts/config-install.sh` (uploaded above)
  - upload configs
    + use Linux Databricks CLI:
      `datbricks fs mkdirs dbfs:/config`
      `databricks fs cp config/departures.conf dbfs:/databricks/config/departures.conf`

* configure job, using the uploaded jar and
  - parameters: `["-c","file:///dbfs/databricks/config/","--feed-sel","ids:download-deduplicate-departures", "--state-path", "file:///dbfs/databricks/data/state", "-n", "SDLB_training"]`

### Further points
* cluster modification/swap possible (scalability)
* recurring schedule
* easy maintainable metastore


#### Showcase
* Workspace -> workflow -> SDLB-train job -> run job
* after finished, show Data -> int_departures table
* show notebook in Workspace
