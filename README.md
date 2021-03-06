# Build Phantomjs for ubuntu-arm32v7

Sadly Phantomjs has no prebuilt version for arm based systems.

But there are two ways for building it:

- compile on Raspbian
- compile in a docker container (ubuntu-arm32v7) on raspbian

The build requirements, build time and the results differ, so it depends massively on the environment.

## Basic setup

I'm using a Rapberry Pi 3 - four cpus will do the job in some hours. But you should give them some more swap space and not run a desktop environment.

The Raspbian is on a 32GB U1 (100MB/s) Micro-SD card - build time depends massively on it's speed. The total space needed is about 3GB.

Edit the file `/etc/dphys-swapfile` - default is 100MB, better comment this line and enable `CONF_SWAPFACTOR=2`.

Set CLI boot mode in raspi-config and reboot - you will not want the UI to play with memory and swap during build.

Unbox you Raspberry Pi - it will really work hard and produce heat for a long time...

Most of the following commands can be done via ssh which is nice for copy/paste the commands. But the building will probably screw up the network or other things so it has to be started on the real console.

Get the best version number and other hints from [http://phantomjs.org/build.html](http://phantomjs.org/build.html), the list of required packages does not perfectly fit to the Raspbian / ubuntu-arm32v7 environment, I've included them here and in the `Dockerfile`, see below for docker building.

## Building on Raspbian

The following commands can be entered via ssh except the `python ./build.py` (network will crash during build).

The `git clone...` and the `git submodule update` will take some minutes for downloading each dependency, stay tuned.

Now let's install the requirements, clone phantomjs, load dependencies (710MB will be loaded, 1.3GB before build, time depends on your network connection plus some minutes for unpacking, checking out):

```bash
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get install g++ flex bison gperf ruby ruby-dev perl libsqlite3-dev libfontconfig1-dev icu-doc libicu-dev libfreetype6 libssl-dev libpng-dev libjpeg8-dev ttf-mscorefonts-installer fontconfig build-essential chrpath git-core libfreetype6-dev openssl
git clone git://github.com/ariya/phantomjs.git
cd phantomjs
git checkout 2.1.1
git submodule init
git submodule update
```

Now start the build on the Raspbian CLI prompt (not ssh connection):

```bash
python build.py --jobs 1
```

Running only one job in parallel takes longer - I had problems when using all four cpus parallel (perhaps heat).

You can interrupt the build with CRTL-Z if you want do peek the memory and process status(`free`, `ps`, `top`). Continue the build with `fg`. Some steps will take several minutes so don't panic if doesn't output anyting. If the system crashes the CRTL-Z will not work - you have to power down.

Watch the run from another system with ssh using `top` - hit SHIFT-M to sort by memory size.

### Restarting build

If you rerun the build please use this for cleaning:

```bash
git submodule foreach git clean -ddfx
python build.py --jobs 1 --git-clean-qtbase --git-clean-qtwebkit
```

### SSL library

There are some possible SSL libs you can use for compiling, `openssl` is used above. But depending on the environment other libs might be available: `libssl1.0-dev`, `openssl-1.0-dev` or others. After installing check the location of the directories in `/usr/include` and `/usr/lib/` and use the `--qt-config` options below for the build command.

https://stackoverflow.com/questions/45498269/error-failed-to-build-phantomjs-building-qt-base-failed told me to use `openssl-1.0-dev` with `--qt-config "-I /usr/include/openssl-1.0/ -L /usr/lib/openssl-1.0/"` but it's not available on raspbian. Check your openssl files.

### JSStringRef.h patch

You might have to apply a patch for JSStringRef.h - see Dockerfile and use it with your path to phantomjs source.

### Result

The resulting bin/phantomjs has 47.9MB on my system. You might want to copy it to some safe place for future reuse.

## Building with Docker

Install Docker with:

```bash
$ curl -sSL https://get.docker.com | sh
$ sudo adduser pi docker
```

Clone this repo and check the `Dockerfile` - it depends on my [uwegerdes/docker-baseimage-arm32v7](https://github.com/UweGerdes/docker-baseimage-arm32v7) which is based on `[arm32v7/ubuntu](https://hub.docker.com/r/arm32v7/ubuntu/)` - the one I will use with Phantomjs. It already includes some of the dependencies.

### Build baseimage

```bash
$ git clone https://github.com/UweGerdes/docker-baseimage-arm32v7.git
$ cd docker-baseimage-arm32v7
$ docker build -t uwegerdes/baseimage -t uwegerdes/baseimage-arm32v7 --build-arg TZ="Europe/Berlin" .
```

The tag `uwegerdes/baseimage` is used with my other dockers that build without problems.
The time zone should be changed to your location.
If you have an apt-cacher-ng server in your network add `--build-arg APT_PROXY="http://192.168.1.18:3142"` to the build command.

### Build the build image

Now build the docker image - it is only the environment and the sources - compiling of phantomjs is done in a container with a volume attached so you have the resulting `bin/phantomjs` outside the container.

```bash
$ docker build -t uwegerdes/build-phantomjs .
```

Wait half an hour for build to complete. The `libicu-dev` version is critical - you might need to recompile phantomjs if you get an error like `error while loading shared libraries: libicui18n.so.52: cannot open shared object file: No such file or directory`.

### Run the build container

With that image you can now start a container to build phantomjs:

```bash
$ docker run -it \
	--name build-phantomjs \
	-v $(pwd):/home/phantomjs \
	uwegerdes/build-phantomjs \
	bash
```

You may create the container over ssh but better not start the build. But here we connect the current directory with the container so the checkout and compiling is saved outside of the container.

Restart the container on your console with:

```bash
$ docker start -ai build-phantomjs
```

### Run the phantomjs build

Start building with:

```bash
$ ./build.sh
```

It will ask you before starting the build so make sure you hit return then. And then wait 7 hours 20 minutes...

### Result

The resulting bin/phantomjs has 43.4MB on my system. You might want to copy it to some safe place for future reuse.

In my other Dockerfiles using phantomjs you find a Dockerfile.arm32v7 which expects to find the precompiled phantomjs in `build/phantomjs/bin/`.

