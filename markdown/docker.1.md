% Python(1) | General Commands Manual
% Alexander Khrulev(AlKhrulev \[at] GitHub)
% 2024-12-07

# NAME

Docker

# SYNOPSIS

TODO

# DESCRIPTION

A collection of useful Docker commands

# DOCKERFILE

`LABEL NAME=VALUE/...docker build --label NAME=VALUE ...`
:   set label, inspectable by **docker inspect** "labels" key

`ARG NAME=VALUE/...docker build --build-arg NAME=VALUE ...`
:   set a build argument(active only for the build duration)

`ENV NAME=VALUE/...docker build --e NAME=VALUE ...`
:   set an env variable(active for the whole image lifespan)

`RUN --mount=type=cache,target=/root/.cache pip install -r requirements.txt`
:   mount a folder to store cache into(on a build server)

`HEALTHCHECK CMD [command...]`
:   **command** returns 0 to indicate "healthy", otherwise "non-healthy"

# Options

`docker build [--name NAME]`
:   provide a name for easy lookup/usage

`docker container ({(create|start)|run}|stop|pause|kill [--signal=SIGNAL]|unpause|rm) CONTAINER_ID`
:   container controls. For **signal**, view **trap -l** in bash

`docker container ls [-a]`
:   list *running* [and stopped/paused] containers

`docker container run [--cap-add=KERNEL_CAPABILITY]... [--cap-drop=KERNEL_CAPABILITY]`
:   ex. **SYS_PTRACE** to enable `strace`, etc. See **capabilities(7)** for the whole list

`docker container run CONTAINER_ID/CONTAINER_NAME`
:   alias to docker **container create** ... && docker **container start** ...

`docker container run [--mount type=bind,target=/local/holder,source=/container/folder[,PERMISSION]]...`
:   create a *read-write* bind module. Add **,readonly** to **mount** args to change it

`docker container run [-v /local/holder:/container/folder[:PERMISSION]]`
:   See above. Add **:ro** to set to readonly

`docker container run [--read-only=true]`
:   Set container's root folder(*/*) to read-only access

`docker container run [--mount type=tmpfs,destination=/tmp,tmpfs-size=256M]...`
:   Useful when root folder is readonly and you need to write into ephemeral space

`docker container run [--mount type=tmpfs,destination=/tmp,tmpfs-size=256M]...`
:   Useful when root folder is readonly and you need to write into ephemeral space

`docker container run [container settings]...`
:   You set container settings here

`docker container update [updated setting]... CONTAINER_ID...`
:   Update (multiple) container settings

`docker container exec CONTAINER_ID COMMAND_TO_EXECUTE`
:   execute a command in a running container. Ex. **docker container exec -it 123 /bin/bash**

`docker run`
:   Deprecated alias to **docker container run**

`docker system prune`
:   clean cache

`docker volume ls|(create|inspect|rm VOLUME_NAME)`
:   add a special volume

`docker container run --mount source=VOLUME_NAME,target=/container/folder`
:   use a volume that can be shared between containers

## Debugging

`docker system events`
:   view system logs

`docker image history IMAGE_NAME[:TAG]`
:   See each layer of your model

`docker container diff CONTAINER_ID`
:   list the changed files and directories in a container᾿s filesystem since the container was created

`docker container stats [OPTIONS] [CONTAINER...]`
:   like **top** for containers

`docker container --rm -it --pid=container:outyet-small --net=container:outyet-small --cap-add sys_ptrace --cap-add sys_admin spkane/train-os /bin/sh`
:   Run a cont. sharing processes(**ps -ef**, **strace**) and networks(**curl**,..) of the one you want to debug. Here, **outyet-small** is being debugged

`docker container export outyet-small -o export.tar`
: get a snapshot of container's filesystem. Useful cause prev. command doesn't have access to that filesystem
