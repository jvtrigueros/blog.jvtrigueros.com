# blog.jvtrigueros.com
Blog.

# Notes: Migrating to Jekyll + S3

Every since I realized that I don't really use my DigitalOcean droplet I decided that it's probably
best that I move the stagnant blog off of DO and into S3 where storage is cheaper and I don't have
to deal with hosting.

## Setup

I'm using the a Docker container generously provided by the Jekyll peeps.

- [jekyll/jekyll](https://hub.docker.com/r/jekyll/jekyll/) Docker container
- [Usage Wiki](https://github.com/jekyll/docker/wiki/Usage:-Running)

I'm running this command on Windows to create blog from scratch:

    docker run --rm -v %userprofile%/workspace/blog.jvtrigueros.com/jekyll:/srv/jekyll jekyll/jekyll jekyll new .

## Developing

To start a Jekyll development server, run the Docker container using the command bellow:

    docker run --rm --name jk -p 4000:4000 -e POLLING=true -v %userprofile%/workspace/blog.jvtrigueros.com/src:/srv/jekyll jekyll/jekyll jekyll serve

It's very intense, but at a high level:

- `--rm` will remove the container when stopped.
- `--name` sets a name for the container (more on that later).
- `-p 4000:4000` binds host port to container port, so that we can access the site (may not need this)
- `-e POLLING=true` sets environment variable to force jekyll to poll filesystem because we're using Docker for Windows
  - More on this on the [Caveats](https://github.com/jekyll/docker/wiki/Usage:-Running#caveats) section.
- `-v ...` mounting this directory to the container's expected location for the source

### Bonus: Live Reload!

The Docker command above will rebuild the blog when file changes are detected but there's nothing that will automatically
refresh your browser's

## Deploying

For deployment, we want to use the `jekyll/jekyll:builder` image because it installs `s3_website` plus other niceties if
needed.

Before deploying, we need to setup `s3_website.yml`:

```bash
> docker run --rm -v %userprofile%/workspace/blog.jvtrigueros.com/jekyll:/srv/jekyll jekyll/jekyll:builder bash -c "jekyll build; s3_website push"

> jekyll --help # This will install Java

> s3_website cfg create # This will create s3_website.yml, edit the yml file with correct creds

> s3_website cfg apply # This will create the s3 bucket etc
```


To deploy, the command is similar to the one above, but it'll only do the build and push:

    docker run --rm -v %userprofile%/workspace/blog.jvtrigueros.com/jekyll:/srv/jekyll jekyll/jekyll:builder bash -c "jekyll build; s3_website push"
