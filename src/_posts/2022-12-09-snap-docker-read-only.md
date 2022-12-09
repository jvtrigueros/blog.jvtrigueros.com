---
layout: post
title: Snap Docker Read-Only Error
date: 2022-12-09 01:30 +0000
---
I repurposed a laptop with a broken display as an Ubuntu server on my local network. I did the installation via the Ubuntu live USB wizard and opted to have it install Docker. I didn't realize that this would install it via [snap](https://snapcraft.io).

Why is this a problem?

> Honestly, it wasn't.

Until I attempted to mount a volume bound to a directory under `/opt/`. I kept getting this error:

```
docker: Error response from daemon: error while creating mount source path '/cache': mkdir /cache: read-only file system.
```

I tried the following:

* Create the directory with my `$USER` and as `root`
* Give the directory `777` access permissions
* Verified that there was enough space in the partition

_Nothing worked._

## Solution

Completely remove the Docker snap

```
sudo snap stop docker
sudo snap remove docker
```

Then install Docker using the [official](https://docs.docker.com/engine/install/ubuntu/) installation instructions.
