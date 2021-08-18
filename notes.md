# Notes: Migrating to Jekyll + S3

Every since I realized that I don't really use my DigitalOcean droplet I decided that it's probably
best that I move the stagnant blog off of DO and into S3 where storage is cheaper and I don't have
to deal with hosting.

## Theme

I'll be using the theme [zetsu](https://nandomoreira.me/zetsu) with a few modifications of my own.
Since it's not a gem-based theme, I'll be cloning the theme as a subtree and see how that works out,
to accomplish this, I'm folowing an [Atlassian guide](https://www.atlassian.com/blog/git/alternatives-to-git-submodule-git-subtree).

First off, we need to add the zetsu repo as a remote

    git remote add -f zetsu https://github.com/nandomoreirame/zetsu.git

Then we can clone the subtree:

    git subtree add --prefix src zetsu master --squash

Then after that we can update the theme if necessary using:

    git fetch zetsu master
    git subtree pull --prefix src zetsu master --squash

## Setup

I'm using the a Docker container generously provided by the Jekyll peeps.

- [jekyll/jekyll](https://hub.docker.com/r/jekyll/jekyll/) Docker container
- [Usage Wiki](https://github.com/jekyll/docker/wiki/Usage:-Running)

I'm running this command on Windows to create blog from scratch:

    docker run --rm -v %cd%/src:/srv/jekyll jekyll/jekyll jekyll new .

## Developing

To start a Jekyll development server, run the Docker container using the command bellow:

    docker run --rm -it --name jk -p 4000:4000 -e POLLING=true -v %cd%/src:/srv/jekyll jekyll/jekyll jekyll serve

It's very intense, but at a high level:

- `--rm` will remove the container when stopped.
- `--name` sets a name for the container, just in case we need to `exec` into the container later.
- `-p 4000:4000` binds host port to container port, so that we can access the site (may not need this)
- `-e POLLING=true` sets environment variable to force jekyll to poll filesystem because we're using Docker for Windows
  - More on this on the [Caveats](https://github.com/jekyll/docker/wiki/Usage:-Running#caveats) section.
- `-v ...` mounting this directory to the container's expected location for the source

### Bonus: Live Reload!

The Docker command above will rebuild the blog when file changes are detected but nothing refreshes your browser, forcing
you to `alt+tab` boo. This can be solved by installing `browser-sync` and have it watch the `_site` directory:

```bash
> npm install -g browser-sync
> browser-sync start -s %cd%\src\_site -f %cd%\src\_site --reload-delay 300 --no-open
```

## Deploying

### Image Optimization

Just adding some notes here, I'm destroying the flow, I'll fix later.

For PNGs or GIFs:

    find _site/assets/ -type f -name *.png -exec convert {} -strip {} \;
    find _site/assets/ -type f -name *.gif -exec convert {} -strip {} \;

For JPEGs:

    find _site/assets/ -type f -name *.jpg -exec convert {} -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace RGB {} \;

For deployment, we want to use the `jekyll/jekyll:builder` image because it installs `s3_website` plus other niceties if
needed.

Before deploying, we need to setup `s3_website.yml`:

```bash
> docker run --rm -it -v %cd%/src:/srv/jekyll jekyll/jekyll:builder bash
> jekyll --help # This will install Java
> s3_website cfg create # This will create s3_website.yml, edit the yml file with correct creds
> s3_website cfg apply # This will create the s3 bucket etc
```

To be able to keep `s3_website.yml` under version control, we'll change the first few lines to obtain
secrets from environment variables:

```yaml
s3_id:  <%= ENV['S3_ID'] %>
s3_secret: <%= ENV['S3_SECRET'] %>
```

More information on this under the [Using environment variables](https://github.com/laurilehmijoki/s3_website#using-environment-variables) section of the `s3_website`
README.

In order for `s3_website` to be able to push to S3, it needs Java installed. So we created `apk.txt` and mounted it. See more on this on this [Github issue](https://github.com/jekyll/docker/issues/142) (specially my comment at the end).

To deploy, the command is similar to the one above, but it'll only do the build and push:

    docker run --rm -v %cd%/src:/srv/jekyll -v %cd%/apk.txt:/srv/jekyll/.apk -e S3_ID=... -e S3_SECRET=... -e JEKYLL_ENV=production jekyll/jekyll:builder bash -c "jekyll build; s3_website push"

The previous command is great for CI/CD, but if you'll be donig a lot of pushing locally, build a
deploy image:

    docker build -t jekyll/jekyll:deploy docker/deploy/

Then you can proceed to run `s3_commands` without the initial overhead:

    docker run --rm -v %cd%/src:/srv/jekyll --env-file .env jekyll/jekyll:deploy s3_website push

**Note: For convenience, you can create a `.env` file with the S3_ID and S3_SECRET variables.**

A few things to note about this approach:

- The `jekyll/jekyll:deploy` only lives locally and it needs to be created on any new machine
- This assumes that the `_site` directory already exists via calling `jekyll build` manually or
  having an external process build it, such as the container in the Developing section.

## WSL

Now that I'm using WSL a lot of the notes above are not that relevant however, most of the workflow has been ported to a Makefile. I've converted the batch files into make tasks.

## WSL2

So now I'm using WSL2, but it's the same as WSL, the only difference is that I'm using LinuxBrew which makes it a bit simpler to manage dependencies.

For this to work, we need to be running Ruby 2.6:

```sh
brew install ruby
```

Then everything must be done in the `src` directory.

So to make sure everything is good to go run:
```sh
bundle install
```

Then from now on use `bundle exec jekyll` for Jekyll commands.
