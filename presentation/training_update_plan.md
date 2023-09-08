- Update:
- CSV: failfast, filename
- StandardizeColNamesTransformer
- note for presenters: use CSV instead of excel for hands-on exercises
- changes:
  + add starting exersice, create first small pipeline step by step with participants
    + add exercise searching for proper action/DO type in Viewer
  + puzzle: add exercise selecting action and DO blocks from shared note books, with specifying proper names in actions
  + later extend run to existing departure.conf etc. and bug fix exercises
- rework second part TBD

Backlog:
+ [ ] preparation:
  + requires Java 11, Java 17 has issue with the selected Hadoop version
  + better test for setup, including a simple copy of a dataFrame
  + better enforce the run through of the preparation
+ [ ] fix partition issue when rerun, better incremental process than overwrite
+ [ ] advertise also via LinkedIn
+ [ ] scala file for analyzing tables like notebook
+ [ ] secret handling
+ [ ] expectations monitoring
- [ ] create a build script to automatically create the version with failures/tasks to fix 
- [ ] merge back improved structure to getting-started
- [ ] create build script, to create the training version 
- [ ] data frame incremental
