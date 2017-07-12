---
layout: post
title: Jekyll Docker Environment
date: 2017-07-12
categories: docker jekyll
---

As you may already know, Windows is my preferred operating system. Ever since Windows 10, the UI has
been super slick and Microsoft as a company has been making moves in the right direction.

It used to be an issue for us, developers, to be able to get work done, but now that we have virtualization,
[Docker](https://docs.docker.com/docker-for-windows/), and [Windows Subsystem for Linux](https://msdn.microsoft.com/en-us/commandline/wsl/install_guide) that's no longer an issue.

This blog was initially written to be used with Ghost, but I found that managing a Ghost service was
way too much overhead for what I wanted to accomplish. I never ever wrote anything and spent most of my
time tweaking the darned thing _(hence the reason this is the second post)_. However, because it was
just Node.js, it was fairly trivial to run on Windows. Still, I wanted out and that's when I turned to
[Jekyll](https://jekyllrb.com/).

### Ruby on Windows

Right off the bat, I hit a wall trying to get Jekyll to work on my machine. Installing Ruby is no longer
an issue with package managers like [Chocolatey](https://chocolatey.org/), yet installing some of the
gem packages require the Ruby development libraries to be built so setting up an environment that I could
work with was turning out to be challenging.

In the past, I've been a big fan of Vagrant, but as I kept using Vagrant I started creating an explosion
of VMs that small things. Usually that's not an issue, but then disk space starts to run out. Fortunately,
there's an alternative -- Docker!

### Jekyll Docker Container

Thanks to the community around Docker, one can go to [Docker Hub](https://hub.docker.com/) and quickly search
for a container that does includes the technology you're seeking to use, in this case it's "Jekyll".

I was able to locate the [Jekyll Docker](https://github.com/jekyll/docker) Github repository, which points to
three available Jekyll images:

- `jekyll/jekyll`: Default image.
- `jekyll/minimal`: Very minimal image.
- `jekyll/build`: Includes tools.

The minimal build _only_ contains Jekyll which is good, but some of the dependencies in my `Gemfile` require
that I have the Ruby development libraries available, which aren't included with the minimal Docker container.
These libraries are in the default image. So we'll stick to using that one. The build image contains other
dependencies that we will not be using.

### Creating a Jekyll Blog

>Before we get started, [Docker for Windows](https://docs.docker.com/docker-for-windows/) must be installed with access to the drive that will contain the blog source.

Let's get started by `cd`ing into the directory in which we want to create the blog, then let's run the
container with a few flags:

    docker run --rm -it --name jk -p 4000:4000 -e POLLING=true -v %cd%:/srv/jekyll jekyll/jekyll:3.5.0 bash

Let's dissect this command:

- `--rm` will remove the container when stopped, stopped containers remain on disk if not removed
- `-it` run the Docker container in interactive mode
- `--name` sets a name for the container instead of having Docker create a name for us
- `-p 4000:4000` binds host port to container port, so that we can view the blog locally
- `-e POLLING=true` enables force polling on Jekyll
  - More on this on the [Caveats](https://github.com/jekyll/docker/wiki/Usage:-Running#caveats) section of Docker Jekyll
- `-v ...` binds `%cd%` to `/srv/jekyll`
  - `%cd%` is the way Windows gives you the current working directory
  - `/srv/jekyll` is the default directory used by the container
- `jekyll/jekyll:3.5.0` the name of the container that we'll be creating an image for along with the version
- `bash` the command that the container should run when created

These are quite a few flags, but it's much more tenable than having to create a Jekyll environment on Windows.

Now that you have a `bash` shell in the Jekyll container, we can start executing commands, so let's create a
Jekyll blog and serve it:

```sh
> jekyll new .
Running bundle install in /srv/jekyll...
...
New jekyll site installed in /srv/jekyll.

> jekyll serve
Configuration file: /srv/jekyll/_config.yml
Configuration file: /srv/jekyll/_config.yml
            Source: /srv/jekyll
       Destination: /srv/jekyll/_site
 Incremental build: disabled. Enable with --incremental
      Generating...
                    done in 0.945 seconds.
 Auto-regeneration: enabled for '/srv/jekyll'
Configuration file: /srv/jekyll/_config.yml
    Server address: http://0.0.0.0:4000/
  Server running... press ctrl-c to stop.
```

This should create a blog from a template and serve it on [http://localhost:4000](http://localhost:4000).
Since we bound the port in the container to our host machine, we should have no issues opening the link in
our browser.

That's it!

You can go ahead and open the `_posts` directory on Windows using your favorite editor and edit away!

On a separate post, I'll go over deployment to an S3 bucket using `s3_website`.

### Bonus: Live Reload!

Even with `POLLING` enabled, you'll notice that when you edit a file, you'll still need to reload your
browser to see any changes. For a much more enjoyable experience we can use [BrowserSync](https://browsersync.io/docs/command-line). On a separate command line session run:

```
> browser-sync start -s %cd%\_site -f %cd%\_site --reload-delay 300 --no-open
[BS] Access URLs:
 ----------------------------------
       Local: http://localhost:3000
    External: http://10.0.75.1:3000
 ----------------------------------
          UI: http://localhost:3001
 UI External: http://10.0.75.1:3001
 ----------------------------------
[BS] Serving files from: C:\Users\jvtrigueros\workspace\blog.jvtrigueros.com\src\_site
[BS] Watching files...
```

This will create another server that will listen on changes on the `_site` directory and reload after
300 ms of a change. So instead of visiting the blog on port 4000, you should instead go to
[http://localhost:3000](http://localhost:3000).
