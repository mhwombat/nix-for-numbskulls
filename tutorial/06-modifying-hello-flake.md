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

That worked before; why isn't it working now?
Earlier we used `nix shell` to enter a *runtime* environment where `hello-flake` was available and on the `$PATH`.
This time we entered a *development* environment using the `nix develop` command.
Since the flake hasn't been built yet, the executable won't be on the `$PATH`.
We can, however, run it by specifying the path to the script.

~~~
$ ./hello-flake
~~~

We can also build the flake using the `nix build` command,
which places the build outputs in a directory called `result`.

~~~
$ nix build
$ result/bin/hello-flake
~~~

Rather than typing the full path to the executable, it's more convenient to use `nix run`.

~~~
$ nix run
~~~


Here's a summary of the more common Nix commands.

-------------------------------------------------------------------------------------
command       Action
------------- -----------------------------------------------------------------------
`nix develop` Enters a *development* shell with all the required development tools
              (e.g. compilers and linkers) available (as specified by `flake.nix`).

`nix shell`   Enters a *runtime* shell where the flake's executables are available
              on the `$PATH`.

`nix build`   Builds the flake and puts the output in a directory called `result`.

`nix run`     Runs the flake's default executable, rebuilding the package first if needed.
              Specifically, it runs the version in the Nix store, not the version in `result`.
-------------------------------------------------------------------------------------

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

What went wrong?
Remember that we are in a *development* shell.
Since `flake.nix` didn't define the `devShells` variable,
the development shell only includes the Nix standard environment.
In particular, the `cowsay` command is not available.

To fix the problem, we can modify `flake.nix`.
We don't need to add `cowsay` to the `inputs` section because it's included in `nixpkgs`, which is already an input.
However, we do need to indicate that we want it available in a develoment shell.
Add the following lines before the `packages = rec {` line.

~~~
        devShells = rec {
          default = pkgs.mkShell {
            packages = [ pkgs.cowsay ];
          };
        };
~~~

Here is a "diff" showing the changes in `flake.nix`.

~~~
$# sed -i '15i\\ \ \ \ \ \ \ \ devShells = rec {\n\ \ \ \ \ \ \ \ \ \ default = pkgs.mkShell {\n\ \ \ \ \ \ \ \ \ \ \ \ packages = [ pkgs.cowsay ];\n\ \ \ \ \ \ \ \ \ \ };\n\ \ \ \ \ \ \ \ };\n' flake.nix
$ git diff flake.nix
~~~

We restart the development shell and see that the `cowsay` command is now available and the script works.
Because we've updated source files but haven't `git commit`ed the new version,
we get a warning message about it being "dirty".
It's just a warning, though; the script runs correctly.

~~~
$# echo '$ nix develop'
$# nix develop --command sh
$ which cowsay # is it available now?
$ ./hello-flake
~~~

Alternatively, we could use `nix run`.

~~~
$ nix run
~~~

Note, however, that `nix run` rebuilt the package in the Nix store and ran *that*.
It did not alter the copy in the `result` directory, as we'll see next.

~~~
$ cat result/bin/hello-flake
~~~

If we want to update the version in `result`, we need `nix build` again.

~~~
$ nix build
$ cat result/bin/hello-flake
~~~

Let's `git commit` the changes and verify that the warning goes away.
We don't need to `git push` the changes until we're ready to share them.

~~~
$ git commit hello-flake flake.nix -m 'added bovine feature'
$ nix run
~~~

## Development workflows

If you're getting confused about when to use the different commands,
it's because there's more than one way to use Nix.
I tend to think of it as two different development workflows.

My usual, *high-level workflow* is quite simple.

1. `nix run` to re-build (if necessary) and run the executable.
1. Fix any problems in `flake.nix` or the source code.
1. Repeat until the package works properly.

In the high-level workflow, I don't use a development shell because I don't need to directly invoke development tools such as compilers and linkers.
Nix invokes them for me according to the output definition in `flake.nix`.

Occasionally I want to work at a lower level, and invoke compiler, linkers, etc. directly.
Perhaps want to work on one component without rebuilding the entire package.
Or perhaps I'm confused by some error message, so I want to temporarily bypass Nix and "talk" directly to the compiler.
In this case I temporarily switch to a *low-level workflow*.

1. `nix develop` to enter a development shell with any development tools I need (e.g. compilers, linkers, documentation generators).
1. Directly invoke tools such as compilers.
1. Fix any problems in `flake.nix` or the source code.
1. Directly invoke the executable. Note that the location of the executable depends on the development tools -- It probably isn't `result`!
1. Repeat until the package works properly.

I generally only use `nix build` if I just want to build the package but not execute anything (perhaps it's just a library).

## This all seems like a hassle!

It is a bit annoying to modify `flake.nix` and ether rebuild or reload the development environment every time you need another tool.
However, this Nix way of doing things ensures that all of your dependencies, down to the exact versions,
are captured in `flake.lock`, and that anyone else will be able to reproduce the development environment.
