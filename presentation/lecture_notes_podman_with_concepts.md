
# Smart Data Lake Builder Hands-On Training

## Houskeeping
* beside the online and onside training you have a budget of 8h
  - including preparation (done)
  - self-paced playing around with SDLB
    + lecture notes: https://github.com/smart-data-lake/getting-started/blob/training/presentation/lecture_notes.md
  - development of use case


<!-- 
Tools: In Teams annotation can be used to point to specific aspects in the configs, SchemaViewer,...
-->

<!-- 
- emphasize that this is and interactive course, motivate for questions
- provide lecture afterwards
- largest commands we past in the chat
- ask to follow along and try yourself, no intensive development today, but goal to use the framework by yourself

- ice breaker, largest amount of data sources or tables you worked with in a single project
-->

## Goal
* train loving friend imagine to **replace** short distant flights **with train** rides
* discover/count all flights which
  - starting from a certain airport 
  - flight distance <500km
  - assume destination airport Bern (LSZB) or Frankfurt (EDDF)

![map about flights around Bern](images/flights_BE.png)

* as data engineers -> provide elevated data for data scientists and business. **General steps**:
  - download data
  - combining/filter/transform data in a general manner
  - store processed data, thus it can be utilized for various use cases
  - analyse/compute data for a specific application

## Smart Data Lake vs. Smart Data Lake Builder

|Smart Data Lake | Smart Data Lake Builder |
|----------------|-------------------------|
| **Concept**    | **Tool**                |
| combines advantages of Data Warehouse and Data Lakes | ELCA's tool to build Data Pipelines efficiently |
| structured data / schema evolution | portable and automated |
| layer approach / processes / technologies | features like historization, incremental load, partition wise |
| Similar to Lakehouse | Open Source on Github: [smart-data-lake](https://github.com/smart-data-lake/) |

## Why Smart Data Lake?
* similar to Lakehouse concept
* combining the flexibility of Data Lakes with the advantages of Data Warehouses
Let's have a closer look.

### Data Warehouse
  - :heavy_plus_sign: preface preparation, structuring and securing data for high quality reporting
  - :heavy_minus_sign: slow changes, less flexible
  - :heavy_minus_sign: no horizontal scaling
  - :heavy_minus_sign: high license cost, expensive
  - :heavy_minus_sign: no unstructured data processing
  - :heavy_minus_sign: insufficient integration of AI
### Data Lake
  - :heavy_plus_sign: performant and flexible
  - :heavy_plus_sign: scalable, open source
  - :heavy_plus_sign: unstructured and complex data structures
  - :heavy_minus_sign: siloed initiatives, redundancy
  - :heavy_minus_sign: heavy data preparation for every use case

### Smart Data Lake or Lakehouse
  - :heavy_plus_sign: value & semantic oriented
  - :heavy_plus_sign: known data quality
  - :heavy_plus_sign: secured, handled privacy
  - :heavy_plus_sign: Metadata (data catalog & linage)
  - :heavy_plus_sign: automation, unified batch and streaming
  - :heavy_plus_sign: AI ready

![data plattforms comparison](images/smartDataLake-dataPlattforms.png)

### Why Smart Data Lake Builder (SDLB)?
* examples of other tools: Snowflake - DBT, Azure Data Factory, Apache Beam, …
  - able to use Smart Data Lake concepts
  - different advantages and disadvantages for building data pipelines
* dynamic creation of workflow (no specification of step ordering)
* No Code for easy tasks
* complex data pipelines well suited
* already implemented loading modes (incremental, partition-wise, streaming, checkpoint/recovery)
* already implemented transformations (historize, de-duplication)
* Designed to add custom connectors and transformations
* various data formats, incl. DeltaLake
* Lineage and Data Catalog from metadata
* DevOps ready: version-able configuration, support for automated testing
* early validation
* scripted -> portable can run on most (maybe any) cloud or on-prem platform
* configuration templates allows reuse of configuration blocks

## Data structuring
Within Smart Data Lake we structure our data in layers

* stage layer 
  - copy of the original data, accessible for merging/combining with existing/other data sources
* integration layer 
  - cleaning/structuring/prepared data
* business transformation layer
  - ready for data analysts/scientists to run/develop their applications

In our case we could think of the following structure:

![data layer structure for the use case](images/dataLayers.png)

## Security In Cloud
* typically data need to be protected against unwanted access and modification, especially in the cloud, where data is by default accessible from everywhere (from everyone, if mis-configured)
* Data Classification: Public, Internal, Restricted, Personal Data, Confidential
  - various security measures per class, including (not the full list):
    + access control
      * strong authentication
      * periodic review of permissions
    + cryptography
      * encrypt at rest and in transit
      * elaborated secret stores, for key management
    + operations security
      * documentation and automation (CD), change management
      * separated environments with configuration and capacity management
    + ...
    + [ELCAs Cloud Security Concept](https://confluence.svc.elca.ch/display/BL9CONFLUENCE/Data+Security+Concept+for+Cloud+Analytics+Platforms)

  - separate treatment of Personally Identifiable Information (PII)
    + e.g. names, address, social sec. numbers, tel.numbers, medical/health data, ...
    + anonymisation (best), pseudonymisation 
    + additional encryption (in use)
    + further regulations: right of data removal, data location restrictions, etc.
    + ...
    + [ELCAs Cloud Data Privacy Concept](https://confluence.svc.elca.ch/display/BL9CONFLUENCE/Technical+Aspects+of+Data+Privacy+Concepts+for+Cloud+Analytics+Platforms)
* authorisation management using roles and permission groups
  - Users belong to role groups
  - role groups have permission groups
  - permission groups mange permissions for apps, devices, and environments
  - ...
  - [ELCAs Cloud Authorisation Concept](https://confluence.svc.elca.ch/display/BL9CONFLUENCE/Authorization+Concept+for+Cloud+Analytics+Platforms)

![permission management from users utilizing role groups and technical groups to specify permissions](images/authorisationConcept.png)

## Setup
* clone repo
  ```
  git clone -b training https://github.com/smart-data-lake/getting-started.git SDLB_training
  ```
  OR update:
  ```
  git pull
  ```
* build additional sources
  ```
  mkdir .mvnrepo
  podman run -v ${PWD}:/mnt/project -v ${PWD}/.mvnrepo:/mnt/.mvnrepo maven:3.6.0-jdk-11-slim -- mvn -f /mnt/project/pom.xml "-Dmaven.repo.local=/mnt/.mvnrepo" package
  ```
* correct permissions: 
  `chmod -R go+w polynote/notebooks`

* start helping containers
  ```
  podman-compose up -d
  ```

## SDLB general aspects
<!--
  during building lets have a closer look to SDLB
-->
* [https://github.com/smart-data-lake](https://github.com/smart-data-lake)
* Scala project, build with Maven
* with different modules: beside the core we have modules for different plattforms, formats and other features
* GPL-3 license 

* we build SDLB core package with additional custom packages. Here we have 2 additional files (Scala classes) with custom web downloader and transformer
* reuse of artifacts from mounted directory in mvn container

## Let's have a look to the actual implementation
as a reminder, we want to implement:
![data layer structure for the use case](images/dataLayers.png)
... which is already prepared in the present repo

In **SDLB**, we define our pipeline by specifying *data objects* and *actions* to connect them, which is done in *HOCON*

## Hocon - Pipeline Description
* **H**uman-**O**ptimized **C**onfig **O**bject **N**otation
* originating from JSON

Let's have a look to the present implementation:
> list config directory: `ls config` -> see multiple configuration files

* specification of the pipeline can be split in **multiple files** and even **directories**
  - -> directories can be used to manage different environments e.g. 

```
config
+-- global.conf
+-- prod
│   +-- injection.conf
│   +-- transform.conf
+-- test
    +-- injection.conf
    +-- transform.conf
```
OR
```
config
+-- env_dev.conf
+-- env_prod.conf
+-- inject
│   +-- dataABC.conf
│   +-- dataXYZ.conf
+-- transform
│   +-- dataABC.conf
│   +-- dataXYZ.conf
```

Let's have a look into a configuration file:
> `less config/airports.conf`
Note: you can also use other viewer/editor, e.g. vim in Ubuntu or SublimeText or Intellij in Windows using `\\wsl$\Ubuntu\home\<username>\...`

* 3 **data objects** for 3 different layers: **ext**, **stg**, **int**
  - here each data object has a different type: WebserviceFileDataObject, CsvFileDataObject, DeltaLakeTableDataObject
  - `ext-airports`: specifies the location of a file to be downloaded 
  - `stg-airports`: a staging CSV file to be downloaded into (raw data)
  - `int-airports`: filtered and written into `DeltaLakeTable`

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

### Schema Viewer - What is supported?
> open [SDLB Schema Viewer](http://smartdatalake.ch/json-schema-viewer/index.html#viewer-page&version=sdl-schema-2.3.0-SNAPSHOT.json)
* distinguish `global`, `dataObjects`, `actions`, and `connections`

### DataObjects
There are data objects different types: files, database connections, and table formats. 
To mention **a few** dataObjects: 

* `AirbyteDataObject` provides access to a growing list of [Airbyte](https://docs.airbyte.com/integrations/) connectors to various sources and sinks e.g. Facebook, Google {Ads,Analytics,Search,Sheets,...}, Greenhouse, Instagram, Jira,...
* `JdbcTableDataObject` to connect to a database e.g. MS SQL or Oracle SQL
* `DeltaLakeTableDataObject` tables in delta format (based on parquet), including schema registered in metastore and transaction logs enables time travel (a common destination)
* `SnowflakeTableDataObject` access to Snowflake tables 

### Actions
SDLB is designed to define/customize your own actions. Nevertheless, there are basic/common actions implemented and a general framework provided to implement your own specification
 
* ``FileTransferAction``: pure file transfer
* ``CopyAction``: basic generic action. Converts to DataFrame and to target data object. Provides opportunity to add **transformer(s)**
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

## Feeds
* start application with `--help`: `podman run --rm --pod sdlb_training sdl-spark --help`

> Note: `-rm` removes container after exit, `pod` for launching in same Network as metastore and Polynote

* `feed-sel` always necessary 
	- can be specified by metadata feed, name, or ids
	- can be lists or regex, e.g. `--feed-sel '.*'`
	- can also be `startWith...` or `endWith...`

* diretories for mounting data, target and config directory, container name, config directories/files

* try run feed everything: 
`podman run --rm --hostname=localhost --pod sdlb_training -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config sdl-spark:latest --config /mnt/config --feed-sel '.*' --test config`
  - Note: data, target and config directories are mounted into the container:

## Environment Variables in HOCON

* error: `Could not resolve substitution to a value: ${METASTOREPW}`
  - in `config/global.conf` we defined `"spark.hadoop.javax.jdo.option.ConnectionPassword" = ${METASTOREPW}`

Task: What is the issue? -> fix issue 
<!-- A collapsible section with markdown -->
> <details><summary>Solution: Click to expand!</summary>
  
> the Metastore password is set while configuring the metastore. In the Metastore Dockerfile the `metastore/entrypoint.sh` is specified. In this file the Password is specified as 1234

> Thus, set environment variable in the container using the podman option: `-e METASTOREPW=1234`

> Note: better not to use clear test passwords anywhere. In cloud environment use password stores and its handling. There passwords should also not appear in logs as plain text. 

> </details>

## Test Configuration
since we realize there could be issues, let's first run a config test:

`podman run -e METASTOREPW=1234 --rm --hostname=localhost --pod sdlb_training -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config sdl-spark:latest --config /mnt/config --feed-sel 'airport' --test config` (fix bug together)

* while running we get:
`Exception in thread "main" io.smartdatalake.config.ConfigurationException: (DataObject~stg-airports) ClassNotFoundException: Implementation CsvDataObject of interface DataObject not found`
let us double check what DataObjects there are available... [SDLB Schema Viewer](http://smartdatalake.ch/json-schema-viewer/index.html#viewer-page&version=sdl-schema-2.3.0-SNAPSHOT.json)

Task: fix issue 
<!-- A collapsible section with markdown -->
> <details><summary>Solution: Click to expand!</summary>
  
> In `config/airports.conf` correct the data object type of stg-airports to *CvsFileDataObject*

> </details>

## Dry-run
* run again (and then with) `--test dry-run` and feed `'.*'` to check all configs: 
  `podman run -e METASTOREPW=1234 --rm --hostname=localhost --pod sdlb_training -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config sdl-spark:latest --config /mnt/config --feed-sel 'airport' --test dry-run`

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
> switch lecturer
## Execution Phases
> real execution: `podman run -e METASTOREPW=1234 --rm --hostname=localhost --pod sdlb_training -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config sdl-spark:latest --config /mnt/config --feed-sel 'airport'`
* logs reveal the **execution phases**
* in general we have: 
    - configuration parsing
    - DAG preparation
    - DAG init
    - DAG exec (not processed in dry-run mode)
* early validation: in init even custom transformation are checked, e.g. identifying mistakes in column names
* [Docu: execution phases](https://smartdatalake.ch/docs/reference/executionPhases)

## Inspect result
* files in the file system: `stg-airport`: CSV files located at `data/stg-airports/`

> <details><summary>Example content</summary>
  
> ```
> $ head data/stg-airports/result.csv
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

### Polynote
* Polynote: tables in the DataLake
  - open [Polynote at localhost:8192](http://localhost:8192/notebook/inspectData.ipynb)
  
## Schema handling
* test the whole pipeline `podman run -e METASTOREPW=1234 --rm --hostname=localhost --pod sdlb_training -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config sdl-spark:latest --config /mnt/config --feed-sel '.*'  --test dry-run `
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
Exception in thread "main" io.smartdatalake.util.dag.TaskFailedException: Task download-deduplicate-departures failed. Root cause is 'AnalysisException: cannot resolve 'foobar' given input columns: [ext_departures_sdltemp.arrivalAirportCandidatesCount, ext_departures_sdltemp.callsign, ext_departures_sdltemp.created_at, ext_departures_sdltemp.departureAirportCandidatesCount, ext_departures_sdltemp.estArrivalAirport, ext_departures_sdltemp.estArrivalAirportHorizDistance, ext_departures_sdltemp.estArrivalAirportVertDistance, ext_departures_sdltemp.estDepartureAirport, ext_departures_sdltemp.estDepartureAirportHorizDistance, ext_departures_sdltemp.estDepartureAirportVertDistance, ext_departures_sdltemp.firstSeen, ext_departures_sdltemp.icao24, ext_departures_sdltemp.lastSeen]; line 1 pos 7;'
```

* SDLB creates Schemata for all spark supported data objects: user defined or inference
    - support for schema evolution 
      + replaced or extended or extend (new column added, removed columns kept) schema 
		+ for JDBC and DeltaLakeTable, need to be enabled

Task: fix issue 
<!-- A collapsible section with markdown -->
> <details><summary>Solution: Click to expand!</summary>
  
> In `config/departures.conf` correct the data object download-deduplicate-departures to not select foobar

> </details>


* run whole pipeline `podman run -e METASTOREPW=1234 --rm --hostname=localhost --pod sdlb_training -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config sdl-spark:latest --config /mnt/config --feed-sel '.*' `
* show results in Polynote
    after the listing tables and schema, we monitor the amount of data in the tables and the latest value
    `departure table consists of 457 row and entries are of original date: 20210829 20210830`

## Automatic Tests
runSimulation -> unit with synthetical DataFrames
[Unit Test in SDLB](https://github.com/smart-data-lake/smart-data-lake/blob/develop-spark3/sdl-core/src/test/scala/io/smartdatalake/workflow/action/ScalaClassSparkDsNTo1TransformerTest.scala#L325)
and
[Corresponding Config File](https://github.com/smart-data-lake/smart-data-lake/blob/develop-spark3/sdl-core/src/test/resources/configScalaClassSparkDsNto1Transformer/usingDataObjectIdWithPartitionAutoSelect.conf)

## Partitions
First have a look at
> ll data/btl-distances

We see all data stored in two sub-directories named with the partition name and value.

Task: recompute *compute-distances* only with/for partition `LSZB` 
Hint: use CLI help

> <details><summary>Solution: Click to expand!</summary>
> to specify a partion, the CLI option `--partition-value` need to be used. Here we need --partition-values estdepartureairport=LSZB
> Execute
> `podman run -e METASTOREPW=1234 --rm -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config --hostname=localhost --pod sdlb_training sdl-spark:latest --config /mnt/config/ --feed-sel ids:compute-distances --partition-values estdepartureairport=LSZB`

> </details>

When you now look at data/btl-distances, you will only see an updated partition estdepartureairport=LSZB and in the logs you find: `start writing to DataObject~btl-distances, partitionValues estdepartureairport=LSZB [exec-compute-distances]`)

Working with partitions forces to create the whole data pipeline around them -> **everything needs to be partitioned** by that key.
The trend goes towards incremental processing (see next chapter).
But batch processing with partitioning is still the most performant data processing method when dealing with large amounts of data.

## Incremental Load
* desire to **not read all** data from input at every run -> incrementally
* or here: departure source **restricted request** to <7 days
  - initial request 2 days 29.-20.08.2021

### General aspects
* in general we often want an initial load and then regular updates
* distinguish between
* **StateIncremental** 
  - stores a state, utilized during request submission, e.g. WebService or DB request
* **SparkIncremental**
  - uses max values from **compareCol**
  - *DataFrameIncrementalMode* and *FileIncrementalMode*
 
### Current Example
Let's try out StateIncremental with the action download-deduplicate-departures
* Here we use state to store the last position
  - To be able to use the StateIncremental mode [CustomWebserviceDataObject](https://github.com/smart-data-lake/getting-started/blob/training/src/main/scala/io/smartdatalake/workflow/dataobject/CustomWebserviceDataObject.scala) needs to: 
    + Implement Interface CanCreateIncrementalOutput and defining the setState and getState methods
    + instantiating state variables 
    + see also the [documentation](https://smartdatalake.ch/docs/getting-started/part-3/incremental-mode)
These Requirements are already met.

* To enable stateIncremental we need to change the action `download-deduplicate-departures` and set these parameters of the DeduplicateAction:
  ```
    executionMode = { type = DataObjectStateIncrementalMode }
    mergeModeEnable = true
    updateCapturedColumnOnlyWhenChanged = true
  ```

After changing our config, try to execute the concerned action
  - `podman run -e METASTOREPW=1234 --rm --hostname=localhost --pod sdlb_training -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config sdl-spark:latest --config /mnt/config --feed-sel download`
Now it will fail because we need to provide a path for the state-path, so we add
  - add `--state-path /mnt/data/state -n SDLB_training` to the command line arguments
  - `podman run -e METASTOREPW=1234 --rm --hostname=localhost --pod sdlb_training -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config sdl-spark:latest --config /mnt/config --feed-sel download --state-path /mnt/data/state -n SDLB_training`


* **first run** creates `less data/state/succeeded/SDLB_training.1.1.json` 
  - see line `"state" : "[{\"airport\":\"LSZB\",\"nextBegin\":1630310979},{\"airport\":\"EDDF\",\"nextBegin\":1630310979}]"`
    + > other content we regard later
  - this is used for the next request
* see next request in output of **next run**:
  `CustomWebserviceDataObject - Success for request https://opensky-network.org/api/flights/departure?airport=LSZB&begin=1631002179&end=1631347779 [exec-download-deduplicate-departures]`
> run a couple of times
  - check the [increasing amount of lines collected in table](http://localhost:8192/notebook/inspectData.ipynb#Cell4)


> :warning: When we get result/error: `Webservice Request failed with error <404>`, if there are no new data available. 

## Streaming
* continuous processing, cases we want to run the actions again and again

### Command Line
* command line option `-s` or `--streaming`, streaming all selected actions
  - requires `--state-path` to be set
* just start `podman run -e METASTOREPW=1234 --rm -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config --hostname=localhost --pod sdlb_training sdl-spark:latest --config /mnt/config/  --feed-sel download --state-path /mnt/data/state -n SDLB_training -s` and see the action running again and again
  - > notice the recurring of both actions, here in our case we could limit the feed to the specific action
    `podman run -e METASTOREPW=1234 --rm -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config --hostname=localhost --pod sdlb_training sdl-spark:latest --config /mnt/config/  --feed-sel ids:download-deduplicate-departures --state-path /mnt/data/state -n SDLB_training -s`

  - > monitor the growth of the table
  - > see streaming trigger interval of 48s in output: `LocalSmartDataLakeBuilder$ - sleeping 48 seconds for synchronous streaming trigger interval [main]`

Task: change the streaming trigger interval to 10s
Hint: use Schema Viewer

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
  * SparkStreamingMode
    - single action streaming
      + action -> executionMode -> SparkStreamingMode
  * there are more execution modes ... explore in the SDL code 
    - PartitionDiffMode, FailNoPartitionValuesMode, ...

## Parallelism
    ```
    podman run -e METASTOREPW=1234 --rm -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config --hostname=localhost --pod sdlb_training sdl-spark:latest --config /mnt/config/ --feed-sel airport,download --state-path /mnt/data/state -n SDLB_training >& out.serial
    ```

    ```
    podman run -e METASTOREPW=1234 --rm -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config --hostname=localhost --pod sdlb_training sdl-spark:latest --config /mnt/config/ --feed-sel airport,download --state-path /mnt/data/state -n SDLB_training --parallelism 2 >& out.parallel
    ```

* distinguish 2 types of parallelism
  - within a spark job: the amount of Spark tasks, controlled by global option `    "spark.sql.shuffle.partitions" = 2`
  - parallel running DAG actions of SDLB, by default serial, one by one action
    + see `Action~download-airports[FileTransferAction]: Exec started` and `Action~download-deduplicate-departures[DeduplicateAction]`
    + use command line option `--parallelism 2` to run both tasks in parallel. compare: 
* Without parallelsim (out.serial): Action2 starts only after Action1 is finished
  ```    
       2022-08-04 12:24:18 INFO  ActionDAGRun$ActionEventListener - Action~download-airports[FileTransferAction]: Exec started [dag-30-109]
       2022-08-04 12:24:18 INFO  FileTransferAction - (Action~download-airports) start writing to DataObject~stg-airports [exec-download-airports]
       2022-08-04 12:24:18 INFO  CsvFileDataObject - (DataObject~stg-airports) deleteAll stg-airports [exec-download-airports]
       2022-08-04 12:24:18 INFO  StreamFileTransfer - Copy DataObject~ext-airports:result -> DataObject~stg-airports:stg-airports/result.csv [exec-download-airports]
       2022-08-04 12:24:19 INFO  FileTransferAction - (Action~download-airports) finished writing DataFrame to stg-airports: jobDuration=PT0.984S files_written=1 [exec-download-airports]
       2022-08-04 12:24:19 INFO  ActionDAGRun$ActionEventListener - Action~download-airports[FileTransferAction]: Exec succeeded [dag-30-109]
       2022-08-04 12:24:19 INFO  HadoopFileActionDAGRunStateStore - updated state into file:/mnt/data/state/current/SDLB_training.30.1.json [dag-30-109]
       2022-08-04 12:24:19 INFO  ActionDAGRun$ActionEventListener - Action~download-deduplicate-departures[DeduplicateAction]: Exec started [dag-30-109]
       2022-08-04 12:24:19 INFO  DeduplicateAction - (Action~download-deduplicate-departures) getting DataFrame for DataObject~ext-departures [exec-download-deduplicate-departures]
  ```

* With parallelsim (out.parallel): Action2 starts while Action1 is still running
  ```    
       2022-08-04 12:23:08 INFO  ActionDAGRun$ActionEventListener - Action~download-airports[FileTransferAction]: Exec started [dag-29-93]
       2022-08-04 12:23:08 INFO  ActionDAGRun$ActionEventListener - Action~download-deduplicate-departures[DeduplicateAction]: Exec started [dag-29-94]
       2022-08-04 12:23:08 INFO  DeduplicateAction - (Action~download-deduplicate-departures) getting DataFrame for DataObject~ext-departures [exec-download-deduplicate-departures]
       2022-08-04 12:23:08 INFO  FileTransferAction - (Action~download-airports) start writing to DataObject~stg-airports [exec-download-airports]
       2022-08-04 12:23:08 INFO  CsvFileDataObject - (DataObject~stg-airports) deleteAll stg-airports [exec-download-airports]
       2022-08-04 12:23:08 INFO  StreamFileTransfer - Copy DataObject~ext-airports:result -> DataObject~stg-airports:stg-airports/result.csv [exec-download-airports]
       2022-08-04 12:23:09 INFO  CustomWebserviceDataObject - Success for request https://opensky-network.org/api/flights/departure?airport=LSZB&begin=1630310979&end=1630656579 [exec-download-deduplicate-departures]
       2022-08-04 12:23:09 INFO  FileTransferAction - (Action~download-airports) finished writing DataFrame to stg-airports: jobDuration=PT1.699S files_written=1 [exec-download-airports]
       2022-08-04 12:23:09 INFO  ActionDAGRun$ActionEventListener - Action~download-airports[FileTransferAction]: Exec succeeded [dag-29-93]
       2022-08-04 12:23:09 INFO  HadoopFileActionDAGRunStateStore - updated state into file:/mnt/data/state/current/SDLB_training.29.1.json [dag-29-93]
  ```
- :warning: parallel actions are more difficult to **debug**
    
## Checkpoint / Restart
* requires states (`--state-path`)
  - `podman run -e METASTOREPW=1234 --rm -v ${PWD}/data:/mnt/data -v ${PWD}/target:/mnt/lib -v ${PWD}/config:/mnt/config --hostname=localhost --pod sdlb_training sdl-spark:latest --config /mnt/config/ --feed-sel '.*' --state-path /mnt/data/state -n SDLB_training` 
  -> cancel run to simulate crash (after download phase when seeing in the logs 
  - `(Action~download-airports) finished writing DataFrame to stg-airports: jobDuration=PT0.871S files_written=1 [exec-download-airports]` and
  - `ActionDAGRun$ActionEventListener - Action~download-deduplicate-departures[DeduplicateAction]: Exec succeeded [dag-1-191]`
* stored current state in file: `data/state/current/SDLB_training.1.1.json`
  - see the SUCCESS and CANCELED statements
* restart with the same command
  - notice line at the beginning: `LocalSmartDataLakeBuilder$ - recovering application SDLB_training runId=1 lastAttemptId=1 [main]`
  - notice the changed DAG, no download

## Execution Engines vs Execution Environments
[Go through documentation](https://smartdatalake.ch/docs/reference/executionEngines)
> Look at diagram and explain when which Engine is running: 
> When copying Files, when copying Data from a File to a Spark Table,
> When Transforming Data with Snowflake via Snowpark
> When Transforming Data between Spark and Snowflake

If you are interested in trying out SDLB with Snowflake, you can follow this [Blog Post](https://smartdatalake.ch/blog/sdl-snowpark/)

## SDL Viewer
There is a new extension of SDLB which visualize the configuration and its documentation. This acts as an data catalog and presents beside the dependencies (DAG) all metadata information of dataObject and Actions. 
The viewer runs in a separate container and can be launched browsing to [localhost:5000](http://localhost:5000).
> Note: there is still an issue with parsing "unresolved" variables. If you see just "Loading", uncomment out the `$METASTOREPW` in `config/global.conf`.


# Deployment methods
* SDLB can be deployed in various ways on various platforms
* distinguish running SDLB as:
  - java application
  - containerized
* on-prem or in the cloud

* here we saw containerized locally
* during development we often run the java directly using Intellij in Windows
* in the cloud we have also various options: 
  - jar in Databricks 
  - Containers in Kubernetes (AKS)
  - in Virtual Machines

Here, we want to briefly show the Databricks deployment.

## Databricks
Here we have the Databricks setup already prepared, and briefly present the setup, just to give you an idea.

### Preparation steps (not part of the demonstration)
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

## Further points
* cluster modification/swap possible (scalability)
* recurring schedule
* easy maintainable metastore

  
### Show case
* Workspace -> workflow -> SDLB-train job -> run job
* after finished, show Data -> int-departures table
* show notebook in Workspace

# Homework
* split into groups of **2** or 3
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

## Additional features

* HousekeepingMode
  * When working with many partitions, SDLB offers two modes to perform Housekeeping activities:
    * PartitionRetentionMode:  Keep partitions while retention condition is fulfilled, delete other partitions
    * PartitionArchiveCompactionMode: Archive and compact old partitions -> Is now already covered by Deltalake
* Spark Specific Features: BreakDataFrameLineage and Autocaching

### BreakDataFrameLineage and Autocaching
* By default spark creates a plan of operations and process them if the target element needs to be realized
  - computation is performed again even if the data is written to a dataObject (file, or table,...)
* Spark provides an option called *cache* to keep the created data in memory
* SDLB uses this option by default for all defined dataObjects, thus during the execution of a pipeline each dataFrame is computed only once, even when used multiple times

Let's consider the scenario illustrated in this figure:
![Data linage from JDBC to DeltaLake table to CSV file](images/lineageExample.png)
 
Assuming an implemtation in Spark, e.g. in our Notebook, the code would look like:

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

SDLB automatically caches all DataFrames of dataObjects. (But not intermediate dataFrames defined in an transformer). Thus, Action A2 uses the DataFrame from memory belonging to table3. But table 3 does not need to be re-read, nor recomputed from table1. In spark you would write `dataFrame2.cache`.

However it will still keep the original Spark-Execution DAG, go over it and then realize that some steps are already cached.
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

## Planned
* Monitoring
  - metrics in logs, e.g. size of written DataFrame
* Constrains
  - specify limitations, error/warning when exceeding
* Expectations
  - notifications if diverging from specified expectation, e.g. number of partitions
