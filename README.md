

# Local Development - Run Environment
## Introduction
This configuration allows to run locally the Smart Data Lake Builder, including project specific jar, while supporting data analysis through Polynote.
It assumes you have installed podman and podman-compose on WSL2 Ubuntu (quite easy).

### in WSL2 Ubuntu:

    in ~/.bashrc, define the following to refer to your intellij project configured in windows:
    export PRJ_PATH="/mnt/c/Users/..your..intellij..project..path/SmartDataLake"

    in the following, we will assume that you have your SDLB application configuration in  ${PRJ_PATH}/src/main/resources/application    
            (without the local configuration; local configuration will be defined by the predefined file ./local_config/container_local.conf )
    we will also assume that your input data will be at ${PRJ_PATH}/data/input



    create a run directory in Ubuntu, navigate to it and

    ../run_dir> git clone ...


## Run with Podman and Podman-Compose
### Start Polynote notebooks and Metastore database

    ./run_dir> podman-compose up



### Build sdl_run container image

    open another shell and put your project specific jar as project.jar in your ./run_dir> directory (lightweight version), and then:

    ./run_dir> podman build . --tag sdl_run:latest


### Run sdl_run container

    podman run --rm -v ${PWD}/data:/mnt/data -v ${PRJ_PATH}/data/input:/mnt/data_input -v  ${PRJ_PATH}/src/main/resources:/mnt/config -v ${PWD}/local_config:/mnt/local_config --network=spark sdl_run:latest -c /mnt/config/application,/mnt/local_config --feed-sel myfeed --state-path /mnt/data/state --name myapp > log.log 2>&1

