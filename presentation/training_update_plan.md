- SDLB-Training customers: 
	+ GEAK -> SOTI
    + [ ] PF -> DDB
	+ [x] VBZ -> SOTI 
	+ [x] SBB Datenlabor -> ZKU
- Update:
	+ preparation document with Intellij -> SOTI
		* setup Intellij with its Plugin, Scala, ..., Parquet, (DBeaver)
		* install  (maybe node intellij plugin)
		* git, SDLB download
		* build SDLB
		* check successful run
		* MS Win native Visualizer
			- powershell script to get Vizualizer artifact
			- script ro start Viz
	+ without docker/podman, only Intellij
		* lecture Notes -> SCHM
		  + [x] significantly shorten theory part at the beginning
          + [x] new env var error case
          + [x] local_WSL, local_IntelliJ
          + exercise: add new DO and Action where columns are name and elevation in m  
		* HandsOn -> TBB
 			+ [x] config / envConfig separation
			- [x] no docker -> parquet, ...
              + [x] new case for env Variable usage  
                + [x] in IntelliJ select output path via env Variable
            + [x] fix deduplicate action 
	+ add short exercises for more HandsOn
    + [ ] secret handling
    + expectations monitoring

- create a build script to automatically create the version with failures/tasks to fix 
- merge back improved structure to getting-started
- create build script, to create the training version 