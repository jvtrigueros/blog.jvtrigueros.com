---
layout: post
title: Using Metabase with Docker and SQLite
date: 2019-01-01
categories: docker metabase sqlite
---

[Metabase](https://metabase.com), is an application that connects to a existing database allowing you to run analytics
and create charts from their web application.

One of the great things about Metabase is that you can self-host it! Today, we're specifically looking at the
[Running Metabase on Docker](https://metabase.com/docs/latest/operations-guide/running-metabase-on-docker.html)
instructions.

Following the guide, I run Metabase as prescribed and load a small SQLite database:

```
docker run --rm -p 8080:3000 -v $PWD/data/settings.db:/opt/data.db metabase/metabase
```

_Since it's a SQLite database, the container needs to have physical access to the file_

The Metabase application starts on http://localhost:8080 and I am able to begin with the setup. However, as soon as I
submit the initial form, Metabase crashes.

```sh
01-01 20:59:28 DEBUG analyze.fingerprint :: Saving fingerprint for Field 55 'name'
#
# A fatal error has been detected by the Java Runtime Environment:
#
#  SIGSEGV (0xb) at pc=0x000000000000a786, pid=1, tid=0x00007f8984a4cae8
#
# JRE version: OpenJDK Runtime Environment (8.0_181-b13) (build 1.8.0_181-b13)
# Java VM: OpenJDK 64-Bit Server VM (25.181-b13 mixed mode linux-amd64 compressed oops)
# Derivative: IcedTea 3.9.0
# Distribution: Custom build (Tue Oct 23 11:27:22 UTC 2018)
# Problematic frame:
# C  0x000000000000a786
#
# Failed to write core dump. Core dumps have been disabled. To enable core dumping, try "ulimit -c unlimited" before starting Java again
#
# An error report file with more information is saved as:
# /tmp/hs_err_pid1.log
#
# If you would like to submit a bug report, please include
# instructions on how to reproduce the bug and visit:
#   http://icedtea.classpath.org/bugzilla
#
```

But we can't stop there!

At a first glance, I didn't know what the issue could be, but I got curious as to how this image was built, so I checked
out the Github repo. I noticed that the base image used to run Metabase is Alpine based, [`openjdk:8-jre-alpine`](https://github.com/metabase/metabase/blob/master/Dockerfile#L56). So that could be the issue!

I came up with this minimal Dockerfile:

```
FROM openjdk:8-jre-slim

ENV VERSION 0.31.2

WORKDIR /app

ADD https://raw.githubusercontent.com/metabase/metabase/v$VERSION/bin/start /app/bin/
ADD http://downloads.metabase.com/v$VERSION/metabase.jar /app/target/uberjar/

CMD ["bash", "/app/bin/start"]
```

And it worked!!!

So now the full command to use this image would be:

```bash
docker build -t metabase/metabase:v0.31.2-custom -f Dockerfile .
docker run --rm -p 8080:3000 -v $PWD/data/settings.db:/opt/data.db metabase/metabase:v0.31.2-custom
```

This should get give you a Metabase instance that's able to load your SQLite database, I'm currently running that on my
server with no issues. If you find a better way to go about this, I'm all ears!

I searched the [Github Issues](https://github.com/metabase/metabase/issues?q=is%3Aissue+sqlite+sigsegv+is%3Aclosed)
for anything related to this, but there's only one result that's not this problem, so this could be an issue with _my_
configuration alone.
