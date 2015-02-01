# Ember CLI Development in Windows

I like Windows. I have been using it since XP days (_let us forget that Vista ever
happened_). I'm also a software developer, and as much I hate saying this,
developing in Windows can suck.

I have recently started getting into `ember.js` using `ember-cli`. I loved how
easy it is to get started with it and being able to create new parts of your
project by simply typing something like `ember generate controller foo`. But in
Windows, the experience is a bit different...

## Initial experience
Install `ember-cli`

    npm install -g ember-cli

Create an application

    ember new app awesomesauce

Add a route

    ember generate route gravy

Done, done and done!

Let's start the server

    ember serve

```
version: 0.1.12
Livereload server on port 35729
Serving on http://0.0.0.0:4200/

Build successful - 1719ms.

Slowest Trees                  | Total
-------------------------------+----------------
TreeMerger (ExternalTree)      | 393ms
TreeMerger (appAndDependencies) | 166ms
TreeMerger (stylesAndVendor)   | 130ms
Concat: Vendor                 | 108ms
CustomStaticCompiler           | 92ms
```

That was fast!

This sets up a LiveReload server that is listening for our changes to the code,
and if there's a change, the browser automatically refreshes the page. This tightens
the development loop.

So if we edit our route template, we should see output on the terminal

```
file changed templates\gravy.hbs

Build successful - 3273ms.

Slowest Trees                  | Total
-------------------------------+----------------
TreeMerger (stylesAndVendor)   | 585ms
TreeMerger (appAndDependencies) | 437ms
Concat: Vendor                 | 345ms
CustomStaticCompiler           | 339ms
TreeMerger (ExternalTree)      | 254ms
```

That's cool right? But as you can see it takes a whole **3 seconds** before you
actually see the change on your browser. This isn't a very fast and it gets worse
the more changes you make to your project.

## More speed, or lack thereof

The `ember-cli` developers are awesome but the speed problem is an issue with the
way symbolic links are handled in Windows, you can read more about it in this
GitHub [issue](https://github.com/ember-cli/ember-cli/issues/1558).

There are [a](http://www.ember-cli.com/#disable-windows-search-index-for-temporary-files)
[few](http://www.ember-cli.com/#disable-windows-defender-for-temporary-files)
[solutions](http://www.ember-cli.com/#symlinks-on-windows) recommended on the
`ember-cli` documentation. I tried all them, but I still suffered from slow compile times.

I thought it was over, I didn't have the patience to wait 3 seconds everytime I
made a change. Sure it may not be a long time, but I had a similar setup in a
different project using `gulp.js` and the wait was close to none. I just couldn't
do it.

I didn't want to use Linux either, not because I'm afraid of it but because WebStorm
looks like poop in Linux. Petty reason, but important to me.

## Virtual machines

Even though I said I didn't want to use Linux, I did so anyway. I set up an Ubuntu
VM on VirtualBox. Installed all of the stuff necessary to get going and it was way
way faster.

But it just looked too ugly.

So this is when I came up with this solution. Using Vagrant and a Samba so that I
can access those files from Windows and have the site built in the VM.
