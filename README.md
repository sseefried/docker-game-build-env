# A `Dockerfile` for provisioning a build environment for Haskell games on Android

## Introduction

Building Haskell games for mobile devices, while possible, isn't that easy.

Apart from requiring a [GHC](http://haskell.org/ghc) cross-compiler, you must cross-compile
various C libraries and then build cross-compiled versions of all the Haskell libraries which,
unfortunately, doesn't work out of the box for some libraries when installing them with
[Cabal](https://www.haskell.org/cabal/).

So, with the aid of [Docker](https://www.docker.com) I wrote a script to build a fully
fledged Android build environment. This builds on earlier work that I did in the
[`docker-build-ghc-android`](https://github.com/sseefried/docker-build-ghc-android) repo.
`docker-build-ghc-android` just builds a GHC 7.8.3 cross-compiler targetting ARMv7, while this
repo builds all the C and Haskell libraries required to build
[Epidemic](https://github.com/sseefried/open-epidemic-game) and other games.

In conjunction with [`android-build-game-apk`](https://github.com/sseefried/android-build-game-apk)
you can build an APK for installation on your Android device.

At the time of writing the important Haskell libraries installed inside the Docker image are:
* HipMunk 
* OpenGLRaw
* SDL2
* sdl2-mixer
* cairo
* elerea
* helm

To see just which libraries are built check the `scripts/` directory of this repo and look at the
`build-*` and `clone-*` scripts in detail. Be aware that many of the libraries are built from
forks of existing libraries and hence may not be completely up-to-date.

## Installation

Please ensure that you are using at least Docker version 1.10. Check with `docker version`.

### (Optional) Build `debian-wheezy-ghc-android`

You probably only want to do this if for some reason you can't download
`sseefried/debian-wheezy-ghc-android` from the
[Docker Hub](https://registry.hub.docker.com/search?q=library) registry. It's rather large
at 1.1G.

Follow the instruction in the `README.md` [here](https://github.com/sseefried/docker-build-ghc-android).

Once you've done that you'll need to tag the resulting image as `sseefried/debian-wheezy-ghc-android`
locally to build the image this `Dockerfile` specifies.

### Build with Docker

At the command line simply type:

    $ docker build .

This will take a while to build. First, unless you performed the previous step, Docker must download
the image `sseefried/debian-wheezy-ghc-android` (about 1.1G). It will then download, clone and build
a bunch of libraries.

Go get a coffee, drink it slowly, notice that the build is still going, 
go for a long walk and then come back. Once it's finished type:

    $ docker images

You will get something like:

    REPOSITORY                            TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    <none>                                <none>              3b16cf90e485        6 minutes ago       6.083 GB
    ...

You can tag the image with something memorable like:

    docker tag <image id> android-haskell

You can now build and install your game.

### Building your game

The basic process is to mount two repos inside a running Docker container and build there.
The two repos are:

* your game repo
* the [`android-build-game-apk`](https://github.com/sseefried/android-build-game-apk) repo

First create a directory on the host machine to contain the two repos (e.g. `/path/to/host-code`)
Then on the host machine:

    $ cd /path/to/host-code
	$ git clone <your game repo>
    $ git clone https://github.com/sseefried/android-build-game-apk
    $ docker run -v /path/to/host-code:/home/androidbuilder/host-code -it android-haskell /bin/bash

(This will _shadow_ the directory in the Docker container (effectively overwriting it
for your purposes). Fortunately the path `/home/androidbuilder/host-code` does not exist inside
the Docker image)

Now, inside the interactive shell in the running container, follow the instructions in the
`README.md` [here](https://github.com/sseefried/android-build-game-apk)

Once you are done the APK will be in `/path/to/host-code/android-build-game-apk/bin` on your
host machine, and you can install it with the following. Remember, do this from the
_host machine_ not the running Docker container.

     $ adb install -r <name.of.the.game.apk>

If you have difficulty getting this to work it may be because you have not enabled
Developer Mode. You can read more on how to do this 
[here](http://www.androidcentral.com/how-enable-developer-settings-android-42).


## Optional reading: Guiding principles of the Dockerfile

Here I outline some of the guiding principles behind the design of the `Dockerfile`.

* Download specific versions of libraries. Check them against a SHA1 hash.
* `cabal install` specific versions of libraries
* `git clone` specific commits of repositories

This way we increase the likelihood that Docker will complete the build into the future.

### Why so many small scripts?

I call these *scriptlets*. Apart from logically structuring the `Dockerfile` so that each library is
built in isolation, this also means I can take advantage of Docker's cache which is a form of
filesystem checkpointing. See a blog
[post](http://lambdalog.seanseefried.com/posts/2014-12-12-docker-build-scripts.html) I wrote on
this. Also see the next question.

### Why do you `ADD` a script just before `RUN`ning it?

This made developing this build script that much easier. While developing a specific *scriptlet* I
didn't want to have to build from the beginning each time I made a small change. Docker's caching of
sub-images meant that I could start building again from the point where a scriptlet changed and know
with 100% certainty that the filesystem was in *exactly* the same state it was the last time I tried
to build from that point. As a consequence the structure of "adding just before running" also makes this
`Dockerfile` more maintainable.
