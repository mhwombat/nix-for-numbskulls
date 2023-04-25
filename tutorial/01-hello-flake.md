---
title:  'A Beginner-friendly Flake Tutorial'
subtitle: '\emph{\today}'
author: 'Amy de Buitléir'
mainfont: DejaVu Sans
monofont: Noto Sans Mono
fontsize: 10
margin-top: 2cm
margin-bottom: 2cm
margin-left: 2cm
margin-right: 2cm
toc: true
toc-depth: 2
number-sections: true
listings: true
colorlinks: true
hyperrefoptions:
- linktoc=all
- hyperfootnotes=true
- colorlinks=true
include-in-header:
- header-extras.tex
...

# Hello, flake!

Before learning to write Nix flakes,
let's learn how to use them.
I've created a simple example of a flake in this git [repository](https://codeberg.org/mhwombat/hello-flake).
To run this flake, you don't need to install anything;
simply run the command below.
The first time you use a package, Nix has to fetch and build it, which may take a few minutes.
Subsequent invocations should be instantaneous.

~~~
$ nix run "git+https://codeberg.org/mhwombat/hello-flake"
~~~

That's a lot to type every time we want to use this package.
Instead, we can enter a shell with the package available to us, using the `nix shell` command.

~~~
$ nix shell "git+https://codeberg.org/mhwombat/hello-flake"
~~~

In this shell, the command is our `$PATH`, so we can execute the command by name.

~~~
$ hello-flake
~~~

Nix didn't *install* the package; it merely built and placed it in a directory called the "Nix store".
Thus we can have multiple versions of a package without worrying about conflicts.
We can find out the location of the executable, if we're curious.

~~~
$ which hello-flake
~~~

Once we exit that shell, the `hello-flake` command is no longer available.

~~~
$ exit
$ hello-flake
~~~

Actually, we can still access the command using the store path we found earlier.
That's not particularly convenient, but it does demonstrate that the package remains in the store for future use.

~~~
/nix/store/0xbn2hi6h1m5h4kc02vwffs2cydrbc0r-hello-flake/bin/hello-flake
~~~
