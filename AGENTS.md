# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

Companion code for the [Smart Data Lake Builder (SDLB) Getting Started guide](https://smartdatalake.ch/docs/getting-started/setup).
It is a **teaching repository**, not a library: it builds a small aviation data pipeline
(download airports + flight departures → join → compute flight distances) in incremental
steps that mirror the chapters of the guide.

The guide's prose lives outside this repository — its source is at
<https://github.com/smart-data-lake/smart-data-lake/tree/develop-spark4/docs/docs/getting-started>.
Read it before changing anything under `config/` or `src/main/scala/com/sample/`: those files
are the guide's worked examples, so a change here without a matching change there leaves the
tutorial inconsistent.

There are no test sources (`src/test` does not exist) despite the `scalatest` dependency
inherited from the parent POM.

## The `.part-*` convention and `prepare.sh` (read this first)

`config/` and `src/main/scala/com/sample/` contain **only** template/variant files — none of
the files SDLB actually loads are committed. SDLB reads `*.conf` from its `--config`
directories, so the `.part-*` suffix keeps a variant invisible to the config loader until it
is activated by copying over the real name.

**Use `./prepare.sh` rather than copying by hand:**

```bash
./prepare.sh --list                  # the part -> file mapping
./prepare.sh 3                       # seed the working tree to START part 3
./prepare.sh final --clean           # the finished pipeline, clearing previous run output
./prepare.sh 2 --validate            # seed, then check the config with SDLB --test config
./prepare.sh 3 --dry-run             # show what would change
```

**`prepare.sh <part>` seeds the state a reader *starts* that part from, which is the previous
part's solution** — `prepare.sh 3` lays down the part-2 solution (plus
`dev.conf.part-2-solution` and the initial `CustomWebserviceDataObject`), not the part-3 one.
`final` is the completed pipeline. Getting this backwards is easy; `--list` is authoritative.

Consequences worth remembering:
- A fresh clone **cannot run** — `config/` holds nothing but `global.conf` and
  `config.template`. Seed a part before building or running anything.
- **`part-Xa` / `part-Xb` variants are intermediate results of the sub-chapters within a part**,
  kept for comparison while working through it. They are *not* seeding targets, and they are
  not a linear sequence: each covers only what its sub-step changes, so pairing them by
  suffix alone produces configs that do not resolve (`btl.conf.part-1a-solution` inputs
  `int-airports`, which `airports.conf.part-1a-solution` does not define but
  `part-1-solution` does).
- `airports.conf.part-1b-solution` deliberately uses a non-existent `UnicornFileDataObject`
  to demonstrate SDLB's config error messages — it is meant to fail.
- `CustomWebserviceDataObject.scala.part-3a-initial` is the deliberately incomplete exercise
  version (it carries a `// REPLACE BLOCK` marker); the `-solution` variants are finished code.
- Edits belong in the `.part-*` variants if they are meant to persist — the activated copies
  are untracked and are overwritten by the next `prepare.sh`. When changing behaviour, apply
  it to **every** affected variant, not just the active copy.

## Build and run

Requires Java 17. The project builds against `sdl-parent:3.0.0-SNAPSHOT` from
`https://central.sonatype.com/repository/maven-snapshots/`.
Note the workflow's auto-bump cannot recover from an *unresolvable*
parent pin, because Maven must resolve the current parent before
`versions:display-parent-updates` will run.

```bash
mvn clean package                     # build the thin getting-started.jar
mvn clean package -Pgenerate-catalog  # also generate + compile the Lab catalog (see below)
```

Run the pipeline with Maven, feeding the classpath to a plain `java` process:

```bash
mvn -B exec:exec -Dexec.executable="java" -Dexec.args="$JAVA_OPTIONS -cp %classpath \
  io.smartdatalake.app.DefaultSmartDataLakeBuilder \
  --feed-sel .* --config ./config,./envConfig/dev.conf --state-path viz/state -n getting-started"
```

- `$JAVA_OPTIONS` must be the long `--add-opens=java.base/...` list — Spark on Java 17
  fails without it. Canonical copies live in `spark/entrypoint.sh`, the
  `Config for Incremental Mode` step of `.github/workflows/ui-build.yml`, and the
  IntelliJ run configuration `.idea/runConfigurations/SDLB.xml`.
- `DefaultSmartDataLakeBuilder` is the entrypoint. SDLB 3.0.0 removed
  `LocalSmartDataLakeBuilder` and `SparkSmartDataLakeBuilder`; the Spark master now comes
  from the engine connection (see Architecture), not from the choice of main class.
- `--feed-sel` selects actions by their `metadata.feed`: `download`, `compute`, or `.*`.
- **Working directory matters.** Relative `path`s in DataObjects resolve against the
  process CWD, and everything expects that to be `data/` — the IntelliJ config sets
  `WORKING_DIRECTORY=$PROJECT_DIR$/data`, the container sets `-Duser.dir=/mnt/data`. When
  running via `mvn exec` from the repo root, output lands in the repo root instead.
- `--state-path viz/state` is what makes runs incremental *and* feeds the UI. Dropping it
  makes every run a full reload.

### Containerized run (podman)

```bash
./buildJob.sh        # mvn package inside maven:3-eclipse-temurin-17, with -Pgenerate-catalog
./buildSpark.sh      # build the sdl-spark image (Spark distro + SDL libs from -Pcopy-libs)
./buildSpark.sh --build-arg SPARK_VERSION=4.1.1   # pin the Spark patch version (needed today)
./startJob.sh --config /mnt/config,/mnt/envConfig/dev.conf --feed-sel .*
CLASS=io.smartdatalake.app.DefaultSmartDataLakeBuilder ./startJob.sh ...  # override main class
```

`startJob.sh` mounts `data/`, `target/`, `config/`, `envConfig/` and the three `viz/`
subdirectories into the container; the app jar is picked up from the `/mnt/lib` mount
rather than baked into the image, so `mvn package` output is used live. `entrypoint.sh` sets
`-Duser.dir=/mnt/data`, so a container run writes its tables into `data/` where a local run
writes them into the repository root — `prepare.sh --clean` clears both.

The image carries the Spark distribution and the SDL libraries (`-Pcopy-libs`, which scopes
Spark, Hadoop and Hive out of `/opt/app/lib` so they come from the distribution instead); the
Spark version is not pinned in the Dockerfile but resolved at build time. 

## Architecture

**Everything is HOCON configuration.** A pipeline is a set of `dataObjects` (where data
lives) wired together by `actions` (how data moves/transforms). Scala code exists only
where config cannot express something.

- **Config assembly**: SDLB merges every `*.conf` under `--config` paths, so files split by
  domain (`airports.conf`, `departures.conf`, `btl.conf`) and by concern (`global.conf` for
  the engine connection and environment flags) combine into one configuration. A given config
  object must be defined in exactly one file — SDLB rejects one split across files, so a
  connection cannot be partly overridden per environment.
- **Environment indirection**: `envConfig/<env>.conf` defines an `env { ... }` block
  (`catalog`, `database`, `basePath`, `tablePathWithId`) that domain configs reference via
  HOCON substitution (`path = ${env.tablePathWithId}`). Exactly one env file is passed per
  run, which is how the same configs target local files, Databricks, etc.
  `~{id}` inside a path is expanded by SDLB to the DataObject's id.
- **Engine connection**: since 3.0.0 the Spark session is configured by a
  `SparkClassicConnection` under `connections`, not by `global.spark-options`. Actions pick one
  via `engineConnectionId`, defaulting to the id named by the SDLB parameter
  `defaultEngineConnectionId` (default `default-engine`). `config/global.conf` defines two:
  `default-engine` with `master = "local[*]"` for local runs, and `cluster-engine` with `master`
  unset so SDLB attaches to a session the environment provides — select that one with
  `SDL_DEFAULT_ENGINE_CONNECTION_ID=cluster-engine` or `-Dsdl.defaultEngineConnectionId=...`
  (`getSdlParameter` reads `sdl.<key>` system properties, `SDL_<KEY>` env vars, or
  `global.environment.<key>`). **This must live in `config/`, not `envConfig/`**: only part-2
  onward loads an envConfig file, and the IntelliJ run configuration passes `-c .../config`
  alone, so defining it in `envConfig/` makes every other part fail with
  "Connection~default-engine not found in instance registry".
  `default-engine` also sets `enableHive = true`, which is what gives the run a persistent
  Derby metastore in `./metastore_db` instead of a per-JVM in-memory catalog. Table
  registrations then survive the process, which `DataObjectSchemaExporter` depends on — it
  looks its Delta tables up by name through the session catalog, in a JVM of its own.
  `SparkClassicConnection` defaults this to `false` and SDLB 3.0.0 no longer pulls `spark-hive`
  in transitively, so `pom.xml` declares it (see Dependency management); without it, enabling
  Hive fails the run with "Unable to instantiate SparkSession with Hive support because Hive
  classes are not found", and without enabling Hive the export fails with
  "`default`.`btl_distances` is not a Delta table".
- **Layer naming** encodes pipeline stage in the DataObject id: `ext-` (external source,
  e.g. `WebserviceFileDataObject`) → `stg-` (raw staged file) → `int-` (cleaned/historized)
  → `btl-` (business transformation layer, `DeltaLakeTableDataObject`).
- **Feeds and metadata**: `metadata.feed` on each action is the unit of scheduling
  (`--feed-sel`); `metadata.layer`, `tags`, `description` are consumed by the exporters and
  rendered in the UI.
- **Action types** in play: `FileTransferAction` (download), `CopyAction` (1→1 with
  transformers), `DeduplicateAction`/`HistorizeAction` (SCD handling in `int-`),
  `CustomDataFrameAction` (n→m, needed for joins). Transformers chain within an action —
  `SQLDfTransformer`/`SQLDfsTransformer` for SQL, `ScalaClassSparkDfTransformer` to call
  into `com.sample`. In SQL, DataObject ids appear as table names with hyphens replaced by
  underscores (`int-departures` → `int_departures`).

**Scala extension points** (`src/main/scala/com/sample/`):
- `ComputeDistanceTransformer` implements `CustomDfTransformer` — the pattern for a
  transformation referenced by `ScalaClassSparkDfTransformer`.
- `CustomWebserviceDataObject` implements `DataObject with CanCreateSparkDataFrame`, and in
  the part-3 solution adds `CanCreateIncrementalOutput` (`setState`/`getState`) to persist
  the last-queried watermark into the state file — this is the incremental-load mechanism
  the guide builds up to.

**Dependency management is inherited.** `pom.xml` is deliberately thin: `sdl-parent`
supplies Spark/Scala version alignment and plugin management, including the `copy-libs`
profile `buildSpark.sh` relies on. SDL artifacts are pinned to `${project.parent.version}`,
so bumping the parent bumps everything. Scala version is inherited too — the parent defaults
to `scala.minor.version=2.13` / `scala.version=2.13.17`, and 3.0.0 publishes **only** `_2.13`
artifacts, so do not reintroduce a 2.12 override. Two explicit additions this project needs:
`sdl-spark` (Spark support was split out of `sdl-core` in 3.0.0), `spark-hive` (dropped from
`sdl-spark`'s dependencies in 3.0.0, still needed for the local Derby metastore — the parent
manages its version and scope) and `guava` at `compile`
scope (upstream marks it `provided` on the assumption a Spark distribution supplies it, but
`mvn exec:exec` uses only the Maven runtime classpath, where `delta-spark` needs it).

## Visualization UI (`viz/`)

`viz/` hosts the prebuilt [sdl-visualization](https://github.com/smart-data-lake/sdl-visualization)
SPA plus the data it renders. Tracked: `viz/state/`, `viz/description/`, `lighttpd.conf`,
`manifest.json`. Gitignored: the app bundle (downloaded on demand), `exportedConfig.json`, and
the schema documents under `viz/schema/` — the workflow regenerates those on every run and
deploys them with `viz/`, and it commits only `viz/state/` back to the repository, so there is
nothing for a tracked copy to stay in sync with. `viz/schema/.gitkeep` keeps the directory
itself.

```bash
./updateViz.sh   # fetch latest sdl-visualizer.zip from nightly.link, preserving local config
./startViz.sh    # symlink config/, serve viz/ via lighttpd (port from viz/lighttpd.conf)
./exportConfigSchemaStats.sh   # export exportedConfig.json + schema/statistics for the UI
```

The exporters run as regular SDLB main classes:
`io.smartdatalake.meta.configexporter.ConfigJsonExporter` (config graph +
`--descriptionPath viz/description` markdown) and `...DataObjectSchemaExporter` (schemas and
statistics). `viz/build_index.sh` rebuilds `viz/state/index.json`; normal runs append to it
automatically.

3.0.0 changed the schema export file naming: one `DataObject~<id>.schema.json` /
`DataObject~<id>.stats.json` per DataObject, replacing 2.x's timestamped
`<id>.schema.<epoch>.json` plus `<id>.schema.index`. The 2.x files committed by the last green
CI run (March 2024) were removed, since nothing rewrote or removed them.
`DataObjectSchemaExporter` also gained `--mode plan|apply` for writing table and column
comments back into the catalog (see Gotchas).

Both exporters take a `--target` URI, and the scheme decides the shape of the output: a bare
path or `file:` is a hadoop path, i.e. an output **directory**, while `localfile:` writes a
single file. This matters only for `ConfigJsonExporter`, whose output is one document —
`--target ./viz/exportedConfig.json` silently produces `viz/exportedConfig.json/exportedConfig.json`
and exits 0. Use `localfile:`, as `ui-build.yml` and `exportConfigSchemaStats.sh` now do. The
deprecated `--filename` and `--exportPath` flags map onto the same directory semantics.

## Lab / interactive exploration

`-Pgenerate-catalog` runs `io.smartdatalake.lab.LabCatalogGenerator`, which reads the config
and emits typed accessors into `src/main/scala-generated/` (gitignored). `sparkShell.sh`
starts a Spark shell preloaded with `InitSDLBInterface.scala`, giving an `sdlb`
(`SmartDataLakeBuilderLab`) handle over the generated `DataObjectCatalog`/`ActionCatalog` so
DataObjects can be queried interactively. Regenerate after changing the config.

## Databricks

`DatabricksDemo.py` is a Databricks notebook (widget-driven: `REPODIR`, `TMPDIR`, `VOLDIR`)
that installs Maven, builds the project, and runs SDLB on a cluster. It pairs with
`envConfig/databricks.conf.template`.

## CI

`.github/workflows/ui-build.yml` on `master` (push, weekly cron, manual): seeds the completed
pipeline with `./prepare.sh final` (it `chmod +x`es it first, because this repo has
`core.fileMode=false` so the script is committed non-executable), auto-bumps the parent to the newest non-feature SDLB snapshot
(`versions:display-parent-updates` → `versions:update-parent`), builds, runs the pipeline,
retries with `-DdataObjects.ext-departures.mockJsonDataObject=stg-departures-mock` if the
live flight API fails, exports schema/stats, **commits the updated `viz/state/` back to
master**, and deploys `viz/` to GitHub Pages. `paths-ignore` on `viz/state/**` and
`viz/schemas/**` prevents that self-commit from re-triggering the workflow.

## Gotchas

- **Table comments are applied at deploy time, not by a pipeline run.** Since
  [#1121](https://github.com/smart-data-lake/smart-data-lake/issues/1121) a run never writes a
  `metadata.description` into the table; `DataObjectSchemaExporter --mode apply` does, together
  with the `@column` comments from `--descriptionPath`. So after a plain run the Delta log holds
  no `description` — that is expected, not a failure. Use `--mode plan` to see what `apply`
  would change. No step in `ui-build.yml` runs `apply`, and the UI reads descriptions from
  `exportedConfig.json`/`viz/description` rather than from the catalog, so nothing depends on
  it here.
  (Historical: on earlier 3.0.0 snapshots a `description` plus `table.catalog = null` made
  `prepare` fail outright, because SDLB emitted Databricks-only `USE CATALOG`. Fixed upstream in
  [#1127](https://github.com/smart-data-lake/smart-data-lake/issues/1127) by addressing tables
  through `table.fullName`.)
- **part-1/2's `departures.conf` variants hardcode a 2021 OpenSky window; `prepare.sh` rewrites
  it.** `departures.conf.part-1/2/2a/2b-solution` carry
  `?airport=LSZB&begin=1630200800&end=1630310979` (August 2021), which anonymous callers can no
  longer fetch: the API limits by *recency* as well as interval width, so a 2h window in 2021 is
  refused just like the original ~30h one. `WebserviceFileDataObject.url` is a plain `String`
  with no expression support, so the window cannot be computed in config — instead `prepare.sh`
  rewrites `begin`/`end` in the *activated* `config/departures.conf` to the last 6h (never in
  the tracked `.part-*` variants). `--keep-timestamps` leaves it as the guide prints it, and
  `--fix-timestamps` rewrites the current file on its own, which is what to use after copying a
  part-2a/2b variant by hand. Part 3 onwards needs none of this — `CustomWebserviceDataObject`
  computes its window in Scala.
- `--test config` validates a config set without touching data:
  `java $JAVA_OPTIONS -cp <cp> io.smartdatalake.app.DefaultSmartDataLakeBuilder --test config
  --feed-sel '.*' --config ./config,./envConfig/dev.conf -n check` (`--test dry-run` also runs
  prepare+init). `ConfigJsonExporter` is *not* a substitute — it checks HOCON structure only and
  accepts an unresolvable `type`, so it passes `airports.conf.part-1b-solution`'s deliberately
  bogus `UnicornFileDataObject`.
- **OpenSky's API limits anonymous queries by window size, not just recency.** A 12h interval
  is served; 18h and beyond return `403 You cannot access historical flights`.
  `CustomWebserviceDataObject.checkQueryParameters` therefore clamps `begin` to 3 days ago and
  caps the interval at `maxIntervalSeconds` (6h), so incremental state from an older run cannot
  drift out of the allowed range — it catches up one interval per run.
- The `-DdataObjects.ext-departures.mockJsonDataObject=stg-departures-mock` retry in CI refers
  to a `stg-departures-mock` DataObject that no configuration defines, so that fallback step
  cannot succeed as written. The `data/stg-*-fallback` fixtures appear to be its intended source.
- The workflow's build step captures Maven output into a backtick assignment under
  `bash -e`, so a Maven failure there produces an empty log and exit code 1 with no error
  text. Run the command locally to see the real message.
- The `Cache Maven` step's key references `steps.get_spark_version.outputs.spark_version`,
  a step that does not exist in this workflow — that key segment is always empty.
- `data/` is gitignored except the `stg-airports-fallback` and `stg-departures-fallback`
  fixtures, used when the external airport/flight APIs are unreachable.
