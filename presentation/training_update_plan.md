Update:
- [x] CSV: failfast, filename 
- [ ] StandardizeColNamesTransformer
- note for presenters: use CSV instead of excel for hands-on exercises
- [ ] changes first part: 
   + [ ] add starting exersice, create first part of airports.conf step by step with participants (2 DO and 1 action)
    + [ ] add exercise searching for proper action/DO type in Viewer
  + [ ] ramaining part of airport.conf via puzzle: add exercise selecting action and DO blocks from shared note books, with specifying proper names in actions

+ [ ] later extend run to existing departure.conf etc. and bug fix exercises
- [ ] quizzes, multiple choice, e.g. what are the best partition column (slido?)
- [ ] incremantal load, pictures from blog post. which pictures would help with our example?
- [ ] rework second part add things from backlog

- [ ] update preparation, send preparation
- sdlb viewer: 
  + add state directory
  + version update

Backlog:
+ [ ] preparation:
  + requires Java 11, Java 17 has issue with the selected Hadoop version
  + better test for setup, including a simple copy of a dataFrame
  + better enforce the run through of the preparation
+ [x] fix partition issue when rerun, better incremental process than overwrite
+ [ ] advertise also via LinkedIn
+ [ ] scala file for analyzing tables like notebook
+ [ ] secret handling
+ [x] expectations monitoring
- [ ] create a build script to automatically create the version with failures/tasks to fix 
- [ ] merge back improved structure to getting-started
- [ ] create build script, to create the training version 
- [ ] data frame incremental 
- [ ] every 2-3 years update default timestamps of webservice. If you get timeouts for some requests (especially for stateincremental mode, this may be the reason: https://github.com/smart-data-lake/smart-data-lake/pull/732/files)
