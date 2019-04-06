---
layout: post
title: An Alternative to grep
categories: linux grep
---

If you spend any amount of time using a terminal, you have more than likely used `grep` to search for phrases or words
in a pile of text files. `grep` is a great tool and it's installed by default on many servers, but if you're a developer,
`grep` doesn't do much aside from a simple text search.

As they say, you gotta use the right tool for the job, for this `ack` is the tool that's very commonly recommended, but
it's less commonly installed. Since we're already needing to install something, I recommend using [The Silver Searcher](https://github.com/ggreer/the_silver_searcher).

## The Silver Searcher

Before adding The Silver Searcher (`ag`) to my toolset, I hadn't heard of `ack`, so if you haven't heard of it yourself,
don't fret. In fact, both `ag` and `ack` share the same API so using one will give you the same muscle memory as the other.
But if you're already using `ack`, I'd recommend trying it out for it's [performance](https://github.com/ggreer/the_silver_searcher#whats-so-great-about-ag):

>Ack and Ag found the same results, but Ag was 34x faster (3.2 seconds vs 110 seconds). My ~/code directory is about 8GB.
Thanks to git/hg/ignore, Ag only searched 700MB of that.

Let's get to it.

## Installing

Getting this on macOS is just a `brew` command away:

```bash
brew install the_silver_searcher
```

On WSL, since it's just Ubuntu you can do this:

```bash
sudo apt install silversearcher-ag
```

For other operating systems (even Windows), check out the [manual](https://github.com/ggreer/the_silver_searcher#installing).

As simple as that, if you're comfortable with `ack` then you can stop here, and reap the benefits of `ag`'s increased
performance!

## Examples

Rather than going into the commands, let's just dive into some examples of how I use `ag` which might provide some useful
patterns.

### Find Usages

Let's say you're exploring a codebase and want to know the usage of a function, `main`:

```bash
ag --clojure main
```
Which gives you this result:

```bash
❯ ag --clojure main
project.clj
7:  :main ^:skip-aot silver-demo.core

src/silver_demo/core.clj
4:(defn -main
```

`ag` ignores searching directories related to version control (.git, .hg) and because we provided a language flag,
`--clojure`, then only Clojure files will be searched. In this case, there are two matches, we get the file path and the
line number of where that word was found.

That's it!

I find myself using this pattern most of the time, IDEs can also do this, but doing this across multiple projects or a
big codebase is rarely a good experience.

### Stats

Sometimes you don't need to know where certain matches are, just that they exist and how many. Using the `--stats-only`
flag will do just that.

Let's try the same query on a much much larger

```bash
❯ ag --clojure --stats-only main
142 matches
35 files contained matches
149 files searched
649117 bytes searched
0.086319 seconds
```

## Conclusion

I described a few use cases for the Silver Searcher (`ag`), I would urge you to try this out and see if it fits in your
terminal toolbox. `grep` is great for some use cases, but if you're searching through code a lot, consider
installing `ag`.
