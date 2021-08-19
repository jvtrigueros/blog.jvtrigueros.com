---
layout: post
title: Migrating to Cloudflare Pages
date: 2021-08-18 17:30 -0700
---
When I first created this blog in 2015 😱, I spent a lot of time bike shedding on questions like:

* Which blogging platform should I use?
* Where should I host this?
* How should I go about hosting it?
* Where should I host it?

I made decisions based on what I thought I knew, but now it's been 7 years and some processes have too much overhead.
Let's look at each decision point and how I changed it to reach our ultimate goal of moving this whole thing to Cloudflare Pages.

### Choosing a blogging platform

Initially, I tried using the [Ghost](https://github.com/TryGhost/Ghost) blogging platform, but ended up turning into a nightmare
because, while it was straightforward to get started, I needed to host this somewhere, and it was more maintenance than I cared
for at the time.

After that, I realized that all I needed was a simple Static Site Generator (SSG), so switched over to [Jekyll](https://jekyll.com)
which is still true to date.

I began with Jekyll 3.4.0 inching my way to present day and landing on Jekyll 4.2.0.

Jekyll is straightforward:

* Create a markdown file with front-matter
* Put it in the `_posts` directory
* Run `jekyll build`
* Bam! Outcomes a static site under `_site`

I did spend a bit of time looking for a theme, and landed on [gets](https://github.com/nandomoreirame/zetsu), which I
customized a bit.

The only issue here was that because I was dead set on using Windows, I created wrapper scripts that would execute Ruby
commands inside a Docker container. This wasn't ideal but it worked.

### Hosting

This is where most of the complexity begins. At the time, GitHub Pages with Jekyll was well-supported, but I didn't
want to host both the source and blog on the same platform. So instead I went to AWS S3.

Hosting in AWS S3 is simple enough, all one has to do is create a public bucket and drop the static site in it.

At this point, we need to create a CNAME in Name.com and the blog will live!

### HTTPS

The issue with the setup above, is that if I wanted to use HTTPS, I needed to add yet another layer -- Amazon CloudFront.

At this point, I should've turned around and reevaluated my decision, but instead I pressed on!

In addition to this new layer, I also needed an SSL certificate for my domain, so I had two options:

* Buy one
* Use Let's Encrypt

I opted to go with [Let's Encrypt](https://letsencrypt.org/), which is a great service that provides free SSL certificates.
The only gotcha is that they only last 90 days.

Once I created the CloudFront distribution, I used a Python CLI tool to generate and update the SSL certificates. Everything
worked great! This commands needs to run every 90 days.

### Continuous Deployment

Copying files to S3 by hand isn't that bad, but I wanted the ability to simply push to the main branch and have something
build the static files and push them to S3. Given how many blog posts I have written, this was definitely a waste of time 😅.

At that time, GitHub Actions wasn't a thing, so I added TravisCI to the mix. Their documentation was great, so it was
trivial to get started.

Where I went wrong is that I opted to use a Ruby Gem called `s3_website` that facilitated uploading files to the S3 bucket
and invalidating the CloudFront cache. This all sounds great, but at some point this gem became unsupported, and it started
to fail, leading to some issues and needed a [workaround](https://github.com/jvtrigueros/blog.jvtrigueros.com/commit/95fc0fa81104388da0cf8852a81c522aee8c4737).

It all still worked!

### Maintenance

There are some _inactive_ resources that I must be aware of but don't require any changes:

* S3 Bucket
* CloudFront distribution
* TravisCI build scripts

But there's one piece that requires *active* maintenance:

* Renew Let's Encrypt certificates every 90 days

Simple, right?
**NO!**

### Problems

Perhaps, I'm the problem here, and maybe I could've automated the process. _However,_ since it was only run every 90
days, I would often forget some steps. 

Yes, I did take notes. Yes, I scripted most of it. Yet, something would fail.

* Wrong Python version
* Wrong package version
* Package deprecated and/or renamed
* Wrong AWS credentials

So this week, I realized that most of my stack was obsolete, and I could move or eliminate parts of it. 
_It was much simpler than I originally anticipated._

## The Great Migration

Before I started any work, I took tally of the pieces that needed to change:

* Blogging platform
  * Unchanged
  * _Technically, I did upgrade the version of Jekyll, but that was unnecessary._
* Hosting
  * S3 ➔ Cloudflare Pages
     * I recently switched my domain name registrar from Name.com to Cloudflare, so this was an obvious choice
* HTTPS
  * CloudFront ➔ Cloudflare
     * Cloudflare would handle both the CDN and ensuring an up-to-date SSL certificate.
* Continuous Deployment
  * TravisCI ➔ Cloudflare Pages
     * Done via GitHub integration, Pages listens for changes on main branch, builds site and publishes it

As you can see, Cloudflare can handle most of the Ops side.

### Cloudflare Pages

It was surprising how simple it was to get this going. To onboard onto Cloudflare Pages, I registered the Cloudflare Pages app
with GitHub to give it access to the blog source. Then entered the build command _and that was it!_

This took care of the Continuous Integration and eliminated the need for S3-type of code hosting. I don't know where the build
artifacts are, and I don't need to know.

Cloudflare Pages serves traffic via HTTPS and when using Cloudflare DNS to route the CNAME to the Pages location, it all
just works. This eliminates the need for manually managing a Let's Encrypt certificate. I don't know where the certificate comes
from, but it is a valid one and that's all I need to know.

Maybe now I won't have an excuse to not write :)

### Less is More

That's all!

If you have a process that you haven't touched in some time, I urge you to take a second look. It may be simpler to update
and improve than you think.
