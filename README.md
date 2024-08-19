# xc-bela-container

Docker image for [Bela](https://bela.io/) development and cross-compilation. Uses GCC 10, CMake and Make for a fast and modular build. By containerizing the cross-compilation toolchain, Bela code can be written and compiled on any host OS that can run Docker, and is compiled much faster and with more flexibility than in the Bela IDE. 

## Quickstart and basic usage

**You can pull the xc-bela-container image from the Docker image hub:**

```bash
docker pull pelinski/xc-bela-container:v1.1.0 
```
There are images for both `amd64` and `arm64` architectures, the pull command will pull the correct one for your machine. If you are on a different machine you will have to build the image yourself (see below).

You can then start a container with (replace the `BBB_HOSTNAME` with the IP address of your Bela – if you are on Windows, it's `192.168.6.2`):

```bash
docker run -it --name bela-container -e BBB_HOSTNAME=192.168.7.2 pelinski/xc-bela-container:v1.1.0
```

You can quit the container with `Ctrl+D` or `exit`. You can start it again with:

```bash
docker start -ia bela-container
```


## Usage tutorial
In this quick tutorial we will cross-compile the `basic` example project in this repo. First we need to copy our project to the Bela projects folder in the container.

```bash
docker cp basic bela-container:/sysroot/root/Bela/projects/
```

Now we need to log into the container:

```bash
docker start -ia bela-container
```

Inside the container, we can compile the project with the following commands (note that these commands are the same you would use in Bela):

```bash
cd /sysroot/root/Bela
make PROJECT=basic -j5 
```

Now we can copy the compiled project to Bela:

```bash
rsync -av /sysroot/root/Bela/projects/basic root@192.168.7.2:Bela/projects/
```

and run it:
```bash
ssh -t root@192.168.7.2 ./Bela/projects/basic/basic
```

## Building the docker image

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
## Advanced stuff
### Cross-compiling with cmake 
If you want to build more complex projects, you can use CMakeLists instead of the default Bela Makefile. 

First, you will need to copy the `libbelafull.so` library from the Docker container into your Bela. You can do so by running, inside the Docker container (you can start it with `docker start -ia bela-container`):

```bash
scp /sysroot/root/Bela/lib/libbelafull.so  root@$BBB_HOSTNAME:Bela/lib/libbelafull.so
```

Now you can copy the project to the container (since we are using CMake, we don't need to copy it into `sysroot/root/Bela/projects/`):

```bash
docker cp basic bela-container:/sysroot/root/
```

To cross-compile the project, we need to tell the compiler that we are cross-compiling for Bela. That information is inside the container, in the `/sysroot/root/Bela/Toolchain.cmake` file. 

You can cross-compile a project by running the following commands inside the container:

```shell
cd /sysroot/root/basic # path to the project
mkdir build && cd build
cmake -DCMAKE_TOOLCHAIN_FILE=/sysroot/root/Bela/Toolchain.cmake  -DPROJECT_NAME=basic ../
cmake --build .
```

You can then copy the compiled project to Bela by running:

```bash
rsync --timeout=10 -avzP /sysroot/root/basic/build/basic root@192.168.7.2:~/
```

You can now run the project in Bela:

```bash
ssh -t root@bela.local ./basic
```


### Building docker images for different architectures
When you build the docker image, it will be built for the architecture of your host machine. If you want to build a docker image for a different architecture, you can use the `buildx` command.

First, you need to enable the `buildx` command. You can do so by running (these commands have been tested on a MacbookPro Intel):

```bash
docker buildx create --name xc-builder --use --driver docker-container
docker run --privileged linuxkit/binfmt:v1.0.0
docker buildx inspect --bootstrap
```
(If you get an error saying that the `xc-builder` already exists, you can remove it by running `docker buildx rm xc-builder`.)


Then, you can build the image for a different architecture by running (replace the `linux/arm64` with the architecture you want to build for):

```bash
docker buildx build --platform linux/arm64 --load -t xc-bela .
```

## Credits
This repo builds on https://github.com/rodrigodzf/xc-bela-container.git. The cross-compiler setup is based on/inspired by TheTechnoBear's [xcBela](https://github.com/TheTechnobear/xcBela). Also of note is Andrew Capon's [OSXBelaCrossCompiler](https://github.com/AndrewCapon/OSXBelaCrossCompiler) and the related [Bela Wiki](https://github.com/BelaPlatform/Bela/wiki/Compiling-Bela-projects-in-Eclipse) page for Eclipse.