# Modifying the flake

Let's make a simple modification to the script.
This will give you an opportunity to check your understanding of flakes.

The first step is to enter a development shell.

~~~
$ cd ~/tutorial-practice/hello-flake
$ nix develop
~~~

The `flake.nix` file specifies all of the tools that are needed during development of the package.
The `nix develop` command puts us in a shell with those tools.
As it turns out, we didn't need any extra tools (beyond the standard environment) for development yet,
but that's usually not the case.
Also, we will soon need another tool.

A development environment only allows you to *develop* the package.
Don't expect the package *outputs* (e.g. executables) to be available until you build them.
However, our script doesn't need to be compiled, so can't we just run it?

~~~
$ hello-flake
~~~

That worked before, why isn't it working now?
Earlier we used `nix shell` to enter a *runtime* environment where `hello-flake` was available and on the `$PATH`.
This time we entered a *development* environment using the `nix develop` command.
since the flake hasn't been built yet, the executable won't be on the `$PATH`.
We can, however, run it by specifying the path to the script.

~~~
$ ./hello-flake
~~~

We can build the  flake.

~~~
$ nix build
~~~

------------------------------------
 command      Action
------------- ----------------------
`nix develop` Enters a *development* shell with all development tools available (as specified by `flake.nix`).

`nix shell`   Enters a *runtime* shell where the flake's executables are available on the `$PATH`.

`nix build`   Builds the

`nix run`     Runs the flake's default executable.

FINISH

BUT FIRST WALK THROUGH THE ACTUAL FLAKE.NIX
