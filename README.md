# blog.jvtrigueros.com
Blog.

# Notes: Migrating to Jekyll + S3

Every since I realized that I don't really use my DigitalOcean droplet I decided that it's probably
best that I move the stagnant blog off of DO and into S3 where storage is cheaper and I don't have
to deal with hosting.

## Developing

I'm using the a Docker container generously provided by the Jekyll peeps.

- [jekyll/jekyll](https://hub.docker.com/r/jekyll/jekyll/) Docker container
- [Usage Wiki](https://github.com/jekyll/docker/wiki/Usage:-Running)

I'm running this command on Windows:

`λ docker run --rm --name jekyll -p 4000:4000 -e POLLING=true -v %userprofile%/workspace/blog.jvtrigueros.com/src:/srv/jekyll jekyll/jekyll jekyll serve`

It's very intense, but at a high level:

- `--rm` will remove the container when stopped.
- `--name` sets a name for the container (more on that later).
- `-p 4000:4000` binds host port to container port, so that we can access the site (may not need this)
- `-e POLLING=true` sets environment variable to force jekyll to poll filesystem because we're using Docker for Windows
  - More on this on the [Caveats](https://github.com/jekyll/docker/wiki/Usage:-Running#caveats) section.
- `-v ...` mounting this directory to the container's expected location for the source