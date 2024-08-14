# xc-bela-container

Docker image for [Bela](https://bela.io/) development and cross-compilation. Uses GCC 10, CMake and Make for a fast and modular build. By containerizing the cross-compilation toolchain, Bela code can be written and compiled on any host OS that can run Docker, and is compiled much faster and with more flexibility than in the Bela IDE. 

<!-- ## Quickstart

**You can pull this container's built image from the Docker image hub:**

built with v0.3.8h 

```bash
docker pull pelinski/xc-bela-container:v0.1.3
```
-->

## Building the docker image and starting a container

You will need to have [Docker](https://docs.docker.com/get-docker/) installed and running. 

Clone this repo:

```bash
git clone https://github.com/pelinski/xc-bela-container.git
cd xc-bela-container
```
Then, connect the Bela to your laptop. If the Bela IP address is not `192.168.7.2` (e.g., in Windows it's `192.168.6.2`), update it in `scripts/build_settings`.

**Note:** The docker image will update the Bela repo branch in your Bela platform to the commit or branch specified in `scripts/build_settings`. Currently it is set to the `dev` branch. 

You can build the docker image using (it will take a while):

```bash
docker build -t xc-bela .
```

Once the image is built is built you can start a container with:

```bash
docker run -it --name bela-container -e BBB_HOSTNAME=192.168.7.2  xc-bela
```

You can quit it with `Ctrl+D` or `exit`. You can start it again with:

```bash
docker start -ia bela-container
```


<!-- -p 8888:8888 -->
## Usage tutorial
In this quick tutorial we will cross-compile the `example-project` in this repo (it's the Bela `fundamentals/sinetone` example).

### Copy libbelafull.so to Bela

First, for the cross-compiled binaries to run in your Bela, you will need to copy the `libbelafull.so` library from the Docker container into your Bela. You can do so by running, inside the Docker container:

```bash
scp /sysroot/root/Bela/lib/libbelafull.so  root@$BBB_HOSTNAME:Bela/lib/libbelafull.so
```

### Copy Bela project into Docker

To cross-compile a project in Docker, copy the project folder into docker.

```bash
docker cp example-project bela-container:/workspace/
```

### Cross-compile project

To cross-compile the project, we need to tell the compiler that we are cross-compiling for Bela. That information is inside the docker, in the `/workspace/Toolchain.cmake` file. 

You can cross-compile a project by running the following commands inside the docker container (you can access it with `docker start -ia bela`):

```shell
cd /workspace/example-project
mkdir build && cd build
cmake -DCMAKE_TOOLCHAIN_FILE=/workspace/Toolchain.cmake ../
cmake --build .
```

You can then copy the compiled project to Bela by running:

```bash
rsync --timeout=10 -avzP /workspace/example-project/build/sinetone root@192.168.7.2:~/Bela/projects/sinetone
```

You can now run the project in Bela:

```bash
ssh root@bela.local
cd Bela/projects
./sinetone
```

## Credits
This repo builds on https://github.com/rodrigodzf/xc-bela-container.git. The cross-compiler setup is based on/inspired by TheTechnoBear's [xcBela](https://github.com/TheTechnobear/xcBela). Also of note is Andrew Capon's [OSXBelaCrossCompiler](https://github.com/AndrewCapon/OSXBelaCrossCompiler) and the related [Bela Wiki](https://github.com/BelaPlatform/Bela/wiki/Compiling-Bela-projects-in-Eclipse) page for Eclipse.
