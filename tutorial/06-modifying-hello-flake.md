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

We can build the flake.
The `nix build` command will build the flake, placing the build outputs in a directory called `result`.

~~~
$ nix build
$ result/bin/hello-flake
~~~

Rather than typing the full path to the executable, it's more convenient to use `nix run`.

~~~
nix run
~~~


Here's a summary of the more common Nix commands.

------------------------------------
command       Action
------------- ----------------------
`nix develop` Enters a *development* shell with all development tools available (as specified by `flake.nix`).

`nix shell`   Enters a *runtime* shell where the flake's executables are available on the `$PATH`.

`nix build`   Builds the flake and puts the output in a directory called `result`.

`nix run`     Runs the flake's default executable.
------------------------------------

Now we're ready to make the flake a little more interesting.
Instead of using the `echo` command in the script, we can use the Linux `cowsay` command.
The `sed` command below will make the necessary changes.

~~~
$ sed -i 's/echo/cowsay/' hello-flake
$ cat hello-flake
~~~

Let's test the modified script.

~~~
$ ./hello-flake
~~~

FINISH

