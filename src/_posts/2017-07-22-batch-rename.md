---
layout: post
title: Batch Rename using PowerShell
date: 2017-07-22
categories: powershell scripts
---

This is more of a self-documenting post, as it doesn't come up often but when it does, it's not
immediately trivial. I'm talking about batch renaming a bunch of files in a folder.

In my particular case, I wanted to make this change:

```
Desktop 06.17.2017 - 22.34.02.01.mp4 -> Ori of the Blind Forest 06.17.2017 - 22.34.02.01.mp4
```

So it's a simple prefix change. Normally, I stay stick to using Command Prompt in
[Cmder](http://cmder.net/). If you haven't used this on Windows, it makes Command Prompt much
more usable. It includes some of the command line tools our friends in Linux land enjoy. Anyway,
for a task like this PowerShell is a much more apt tool because of its extensive built-in
commands.

## TL;DR

If you want to replace the prefix (or any other part) of a filename with another type this
command:

    dir | Rename-Item -NewName {$_.name -replace "old-text","new-text"}

## Explanation

Let's breakdown the commands used here:

1. `Get-ChildItem`
1. `|`
1. `Rename-Item`
1. `{...}`

First, [`Get-ChildItem`](https://technet.microsoft.com/en-us/library/ee176841.aspx) is aliased to `dir`,
but what that command does is output every item in the current directory as an item. The `|`, or pipe, is
used to pass each Item to the `Rename-Item` command.

[`Rename-Item`](https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.management/rename-item)
has the following anatomy (simplified for this use case):

    Rename-Item [-Path] <String> [-NewName] <String>

The `[-Path]` is coming from `dir` and `[-NewName]` is the result of the script block &mdash; `{...}`.
The script block is an anonymous function that executes in place, in this case it is using the automatic
variable, `$_`, which is an Item that came from the pipe. The function calls the `.name` attribute which
returns a String, then we can call it's `-replace` flag which will do what we want.

If we execute this command:

    Rename-Item -NewName {$_.name -replace "Desktop","Ori of the Blind Forest"}

Taking this step by step and execute `dir`:

```
M:\Media\Videos\ShadowReplay\Ori of the Blind Forest
λ  dir

    Directory: M:\Media\Videos\ShadowReplay\Ori of the Blind Forest

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        6/17/2017  10:34 PM       12703402 Desktop 06.17.2017 - 22.34.02.01.mp4
```

So then the command past the pipe will look like this:

    Rename-Item Desktop 06.17.2017 - 22.34.02.01.mp4 -NewName {Desktop 06.17.2017 - 22.34.02.01.mp4 -replace "Desktop","Ori of the Blind Forest"}

Then finally reducing to:

    Rename-Item Desktop 06.17.2017 - 22.34.02.01.mp4 -NewName Ori of the Blind Forest 06.17.2017 - 22.34.02.01.mp4

I hope this helps someone, I know it'll definitely help me in the future!
