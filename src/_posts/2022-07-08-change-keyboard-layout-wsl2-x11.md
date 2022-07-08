---
layout: post
title: Change Keyboard Layout on WSL2 for X11 Apps
date: 2022-07-08 09:48 -0700
---
For better or worse (worse really), I use the [dvorak](https://en.wikipedia.org/wiki/Dvorak_keyboard_layout) keyboard layout. Typically, I manage the layout using the Operating System, which means my physical keyboard is a normal qwerty layout keyboard and it changes to dvorak via software. However, I recently started using an [ErgoDox EZ](https://ergodox-ez.com/) and chose to flash the keyboard's firmware to map physical keyboard to the dvorak layout. I can now plug in this keyboard on any machine, and, without change the OS settings, the keyboard will be in dvorak as expected. NICE!

This worked well up until I tried using Emacs via X11 on WSL2. Ubuntu set my keyboard layout as dvorak (_probably something I set up and forgot about it_), so when using the ErgoDox, none of the keys mapped to the correct value.

## Solution
To solve this, install X11 XKB utilities and use `setxkbmap` to manually change the keyboard layout:

```sh
sudo apt-get install x11-xkb-utils

# Change the layout to qwerty
setxkbmap us

# Change the layout back to dvorak
setxkbmap us -variant dvorak
```

I use [x410](https://x410.dev) to manage the X11 display server, highly recommended. They also have a [cookbook](https://x410.dev/cookbook/keyboard-layout/) on managing your keyboard layout. 
