---
layout: post
title: "DietPi + Gitea: SQLite and CIFS Mount Installation Gotchas"
---
I was recently chatting with a friend about how they manage their `docker-compose`
stacks in their homelab. They told me they used [portainer](https://docs.portainer.io/)
to manage all their containers. So I decided to give it a go.

At a glance, this didn't seem to add much more than my existing setup, which is a `tmux`
session with a pane for each `docker-compose` stack. But then I saw that you can setup a
portainer stack by pointing it to a Git repository. Now this is more appealing! Doing this
allows the following:
* Version controlled `docker-compose.yaml` files
* Trigger stack update via the UI or webhook
* Environment variables via the UI

I was sold!

All I had to do was install portainer, Gitea, and configure a few webhooks, right?

## Planning

My homelab is nothing more than an old laptop running Ubuntu and a Raspberry Pi running DietPi.
I run all my Docker workloads on the laptop and lightweight web applications on the Raspberry Pi.
Both machines do not have a lot of storage, so files are store on my NAS via CIFS mounts. These mounts
are accessed directly or mounted as volumes for Docker containers.

The plan was simple:
* DietPi
  * Install [portainer](https://dietpi.com/docs/software/programming/#portainer) and connect to Ubuntu's `dockerd` via TCP
  * Install [Gitea](https://dietpi.com/docs/software/cloud/#gitea) and create repos for each stacks
  * Create webhooks on portainer and trigger them from Gitea after each push
* Ubuntu
  * Keep everything the same, except create git repos for each stack and publish to Gitea
  
## Execution

As you may have already guessed, nothing went as planned. DietPi makes it super simple
to install software, but when you need to deviate...it is HELL!

## Problems and Solutions

> There's no doubt that if you follow the default instructions on the DietPi's website, you'd have a working Gitea instance in less than 5 mins.

To be clear, we're installing Gitea on a Raspberry Pi running the DietPi distribution.
We will be using SQLite as our database and storing all of Gitea's files on a CIFS mount.

If you're using this a as a guide, at this point, install Gitea using `dietpi-software`
but don't go any further, we'll need to make adjustments.

Here's the list of changes that were required to make this all work.

### Setup `gitea` user

The `gitea` is setup without shell access, but it needs it ¯\\_(ツ)_/¯.

To fix this run:
```sh
useradd -s ${SHELL} gitea
```

This may not be necessary, but I kept seeing LC_LANG warnings to fix that run:
```sh
$ locale-gen
Generating locales (this might take a while)...
  en_US.UTF-8... done
Generation complete.
```

### CIFS Mount Permissions

This change will allow Gitea to create directories in our CIFS mount.

DietPi comes with a helpful utility to mount external drives called `dietpi-drive_manager`,
which I recommend using to add your network drive. Once you do this we'll need to make manual
adjustments.

![dietpi-drive-manager]({{ site.baseurl }}/assets/dietpi-drive-manager.png)

I attempted to read the program's source, and gathered that mounts are managed by `systemd`
using `/etc/fstab` as the source of truth.

The first adjustment we need to set the `gitea` user as the owner of the CIFS mount by setting the
`uid` option to `gitea`. Here's what mine looks like:

```sh
#----------------------------------------------------------------
# NETWORK
#----------------------------------------------------------------
//192.168.1.33/git-hosting /mnt/git-hosting cifs cred=/var/lib/dietpi/dietpi-drive_manager/mnt-git-hosting.cred,iocharset=utf8,uid=gitea,gid=dietpi,file_mode=0770,dir_mode=0770,vers=2.1,nofail,noauto,x-systemd.automount
```

I left `gid` still as `dietpi` to be on the safe side in case there's some other process running as `dietpi` that needs to modify this directory.

**Anytime we modify `fstab`, we need to run `systemctl daemon-reload`**

We can verify that this is working by checking the directory owner:
```sh
$ ls -lah /mnt/git-hosting
total 4.0K
drwxrwx--- 2 gitea dietpi    0 Feb  9 03:53 .
drwxr-xr-x 7 root  root   4.0K Feb  9 04:27 ..
drwxrwx--- 2 gitea dietpi    0 Feb  9 03:53 @Recycle
drwxrwx--- 2 gitea dietpi    0 Feb  9 03:56 gitea
```

### SQLite on a CIFS mount

This step is optional, as you may choose to follow DietPi's recommendation and use the already
installed MySQL database. I chose to deviate because SQLite is simpler, one file to manage and backup.

If you place the database in a CIFS mount, you'll get errors about the database being locked.
This is a known issue and the workaround is to mount the CIFS mount with the `nobrl` option.

> Don't use `nobrl` as the default, this option prevents file locking. Multiple users modifying the same files could lead to corruption.

To enable this, let's modify `/etc/fstab` by adding this option. Follow the same steps above, now my entry looks like so:
```sh
#----------------------------------------------------------------
# NETWORK
#----------------------------------------------------------------
//192.168.1.33/git-hosting /mnt/git-hosting cifs cred=/var/lib/dietpi/dietpi-drive_manager/mnt-git-hosting.cred,iocharset=utf8,uid=gitea,gid=dietpi,file_mode=0770,dir_mode=0770,vers=2.1,nofail,noauto,nobrl,x-systemd.automount
```

Lastly, run `systemctl daemon-reload` to save changes.

For more context, check out [Lee Cheng Hui's](https://lchenghui.com/nobrl-for-mount-cifs) blog post.

### Dropbear SSH Server

By default, DietPi recommends using Dropbear as your SSH Server but it doesn't appear to be
compatible with Gitea if you plan on using SSH authentication.

To fix this, run `dietpi-software` > SSH Server > OpenSSH Server.

![dietpi-ssh-server]({{ site.baseurl }}/assets/dietpi-ssh-server.png)

![dietpi-openssh-server]({{ site.baseurl }}/assets/dietpi-openssh-server.png)

There is a note about OpenSSH Server consuming more resources and, while that may be true,
it was the only way I could get this to work.

### Access Local Ports from Portainer

I've chosen to install Portainer on my DietPi instance using `dietpi-software`,
and the issue I ran into with this setup is that Portainer is unable to access the Gitea
git server running on the same host.

Gitea is running directly on the Raspberry Pi, while Portainer is running in a Docker container.
Here's Gitea's [Portainer](https://github.com/MichaIng/DietPi/blob/6a4b6e0486ffe363f6f75fda6f6d3718ac6aa627/dietpi/dietpi-software#L11784-L11796)
install script. It does some basic sanity checking, but at the end of the day, it's `docker run`
command with the `restart=always` flag.

We can choose to forgo DietPi's version and run this ourselves or modify the `dietpi-software` script.

I chose to modify.

```sh
vim /boot/dietpi/dietpi-software
```

Whichever your choice is, you need to update the `docker run` command by adding `--add-host=host.docker.internal:host-gateway`.
This will allow processes running inside Docker containers to access hosts' processes via `host.docker.internal` instead of `localhost`.

My command now looks like this:
```sh
G_EXEC_OUTPUT=1 G_EXEC docker run -d -p '9002:9000' --add-host=host.docker.internal:host-gateway --name=portainer --restart=always -v '/run/docker.sock:/var/run/docker.sock' -v 'portainer_data:/data' 'portainer/portainer-ce'
```

Again, you can simply run this command without modifying the script.

### Completing Gitea Setup

Up until now we haven't completed the Gitea setup, you should visit the Gitea url running on port 3000 and complete it.
Now we should be able to specify SQLite as the database and choose to store all Gitea's data on our CIFS mount.

You will need to create a user, which will become the administrator of the Gitea instance.
Create a repository with a `docker-compose.yaml` and you should be good to go!

### Webhooks on Portainer and Gitea

Once you have a repository in Gitea, you can add a stack like so:

![portainer-git-repository]({{ site.baseurl }}/assets/portainer-git-repo.png)

Then enable GitOps, to reveal the webhook link.

![portainer-webhook]({{ site.baseurl }}/assets/portainer-webhook.png)

The webhook url may have a host using your `.local` address. This didn't work for me,
so I replaced that with `127.0.0.1` when adding it on Gitea's webhook settings.

![gitea-webhook]({{ site.baseurl }}/assets/gitea-webhook.png)

## Conclusion

After applying all these changes, I can now commit changes to my `docker-compose.yaml` files
push them to Gitea and have it trigger a stack reload if there were any changes.

Discovering all these issues set me back a whole afternoon, so posting it all in hopes it helps
someone else.
