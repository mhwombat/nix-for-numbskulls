---
title:  'A Beginner-friendly Flake Tutorial'
author: Amy de Buitléir
mainfont: DejaVu Sans
fontsize: 10
margin-top: 2cm
margin-bottom: 2cm
margin-left: 2cm
margin-right: 2cm
...

# Using a flake

Before learning to write Nix flakes,
let's learn how to use them.

I've created a simple example of a flake in this [repo](https://codeberg.org/mhwombat/hello-flake).
To run this flake, you don't need to install anything.
Simply run the command below.

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

Once we exit that shell, the `hello-flake` command is no longer available.

~~~
$ exit
$ hello-flake
~~~
