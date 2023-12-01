# xc-bela-container

Docker image for [Bela](https://bela.io/) development and cross-compilation. Uses GCC 10, CMake and Make for a fast and modular build. By containerizing the cross-compilation toolchain, Bela code can be written and compiled on any host OS that can run Docker, and is compiled much faster and with more flexibility than in the Bela IDE. The VSCode environment is also set up for running GDB over SSH, allowing you to debug your Bela programs in the editor.

## Quickstart

**You can pull this container's built image from the Docker image hub:**

```bash
docker pull pelinski/xc-bela-container:v0.1.1
```

This container includes the [pybela + pytorch cross-compilation tutorial](https://github.com/pelinski/pybela-pytorch-xc-tutorial) which you can use as template (If you do not wish to include this when building the container yourself, remove lines 16-26 from `Dockerfile`). This tutorial will show you how to configure your Bela, record a dataset, train a simple model in pytorch and cross-compile the Bela code, all from a jupyter notebook.

Below are the instructions to build the container locally:

## How to build this container

You will need to have [Docker](https://docs.docker.com/get-docker/) installed and running.

### Clone this repo

```bash
git clone --recurse-submodules https://github.com/pelinski/xc-bela-container.git
cd xc-bela-container
```

### Set up your Bela

To build this container, you need to connect your Bela to your laptop. If your Bela address is not `192.168.7.2`, update it in `.devcontainer/devcontainer.env`.

You will need the Bela experimental image `v0.5.0alpha2` which can be downloaded here https://github.com/BelaPlatform/bela-image-builder/releases/tag/v0.5.0alpha2. Follow the instructions [here](https://learn.bela.io/using-bela/bela-techniques/managing-your-sd-card/#flash-an-sd-card-using-balena-etcher) to flash that image onto your Bela.

Follow the instructions below to checkout the Bela repo to commit `73637ab` on the `xc` branch at https://github.com/pelinski/Bela/.

#### Option A: Bela connected to internet

If your Bela is connected to the internet, you can do this by ssh-ing into it and running

```bash
git remote add pelinski https://github.com/pelinski/Bela.git
git fetch pelinski
git checkout xc
```

#### Option B: Bela not connected to internet

If your Bela is not connected to the internet, you can still update the Bela repo running:

```bash
git clone https://github.com/pelinski/Bela.git
cd Bela
git checkout xc
git remote add board root@bela.local:Bela/
git push -f board xc:xc
```

Then, ssh into Bela and run

```bash
ssh root@bela.local
cd Bela
git checkout xc
```

#### Check all libraries are compiling

At this stage you should try to compile one of the Bela examples (you can do so from the IDE) to see if all the libraries are building correctly. If there is any issue compiling the examples, ssh into Bela and run:

```
cd Bela/
make coreclean
make -f Makefile.libraries cleanall
```

and try again.

### Build the docker container

You can run the docker container using

```bash
docker build -t xc-bela .
```

(it will take a while). Once the container is built you can access it with:

```bash
docker run -it --name bela --env-file .devcontainer/devcontainer.env  -p 8888:8888 xc-bela
```

### Copy libbelafull.so to Bela

For the crosscompiled binaries to run in your Bela, you will need to copy the `libbelafull.so` library from the Docker container into your Bela. You can do so by running, inside the Docker container:

```bash
scp /sysroot/root/Bela/lib/libbelafull.so  root@$BBB_HOSTNAME:Bela/lib/libbelafull.so
```

## Usage

### Copy Bela project into Docker

To cross-compile a project in Docker, copy the project folder into docker. To do that, first find the container id (outside the container):

```bash
docker ps
```

identify the container id and run :

```bash
docker cp local-path-to-folder-or-file container-id:path-for-the-folder-or-file-to-be-copied-to
```

### Cross-compile project

Inside of the docker container:

```shell
cd path-to-project
mkdir build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../Toolchain.cmake ../ # correct this relative path if needed
cmake --build .
```

You can then copy the compiled project to Bela by running:

```bash
rsync --timeout=10 -avzP build/project-name root@$BBB_HOSTNAME:~/Bela/projects/project-name
```

You can now run the project in Bela:

```bash
ssh root@bela.local
cd Bela/projects/project-name
./project-name
```

## Credits

All credit for the Bela code goes to Bela and Augmented Instruments Ltd. This project is also licensed under the LGPLv3. This repo builds on https://github.com/rodrigodzf/xc-bela-container.git. The cross-compiler setup is based on/inspired by TheTechnoBear's [xcBela](https://github.com/TheTechnobear/xcBela). Also of note is Andrew Capon's [OSXBelaCrossCompiler](https://github.com/AndrewCapon/OSXBelaCrossCompiler) and the related [Bela Wiki](https://github.com/BelaPlatform/Bela/wiki/Compiling-Bela-projects-in-Eclipse) page for Eclipse.
