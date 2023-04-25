# A new flake from scratch (Python)

At last we are ready to create a flake from scratch!
Start with an empty directory and create a git repository.

~~~
$ cd ~/tutorial-practice
$ mkdir hello-python
$ cd hello-python
$ git init
~~~

Next, we'll create a simple Python program.

~~~
$# curl https://codeberg.org/mhwombat/hello-flake-python/raw/branch/main/hello.py --silent --output hello.py
$ cat hello.py
~~~

Before we pachage the program, let's verify that it runs.
We're going to need Python.
By now you've probably figured out that we can write a `flake.nix` and define a development shell that includes Python.
We'll do that shortly, but first I want to show you a handy shortcut.
We can lauch a *temporary* shell with any Nix packages we want.
This is convenient when you just want to try out some new software and you're not sure if you'll use it again.
It's also convenient when you're not ready to write `flake.nix`
(perhaps you're not sure what tools and packages you need),
and you want to experiment a bit first.

The command to enter a temporary shell is

`nix-shell -p ` *packages*

If there are multiple packages, they should be separated by spaces.
Note that the command used here is `nix-shell` with a hyphen, not `nix shell` with a space; those are two different commands.
In fact there are hyphenated and non-hyphenated versions of many Nix commands, and yes, it's confusing.
The non-hyphenated commands were introduced when support for flakes was added to Nix.
I predict that eventually all hyphenated commands will be replaced with non-hyphenated versions.
Until then, a useful rule of thumb is that non-hyphenated commands are for for working directly with flakes;
hyphenated commands are for everything else.

Let's enter a shell with Python so we can test the program.

~~~
$# echo '$ nix-shell -p python3'
$# nix-shell -p python3 --command sh
$ python hello.py
~~~

Next, create a Python script to build the package.
We'll use Python's setuptools, but you can use other build tools.
For more information on setuptools, see the
[Python Packaging User Guide](https://packaging.python.org/en/latest/guides/distributing-packages-using-setuptools/),
especially the section on
[setup args](https://packaging.python.org/en/latest/guides/distributing-packages-using-setuptools/#setup-args).

~~~
$# curl https://codeberg.org/mhwombat/hello-flake-python/raw/branch/main/setup.py --silent --output setup.py
$ cat setup.py
~~~

We won't write `flake.nix` just yet.
First we'll try building the package manually.

~~~
$ python -m build
~~~

The missing module error happens because we don't have `build` available in the temporary shell.
We can fix that by adding "build" to the temporary shell.
When you need support for both a language and some of its packages,
it's best to use one of the Nix functions that are specific to the programming language and build system.
For Python, we can use the `withPackages` function.

~~~
$# echo '$ nix-shell -p "python3.withPackages (ps: with ps; [ build ])"'
$# nix-shell -p "python3.withPackages (ps: with ps; [ build ])" --command sh
~~~

Note that we're now inside a temporary shell inside the previous temporary shell!
To get back to the original shell, we have to `exit` twice.
Alternatively, we could have done `exit` followed by the `nix-shell` command.

~~~
$# echo '$ python -m build'
$# python -m build > /dev/null 2>&1
~~~

After a lot of output messages, the build succeeds.

Now we should write `flake.nix`.
We already know how to write most of the flake from the examples we did earlier.
The two parts that will be different are the development shell and the package builder.

Let's start with the development shell.
It seems logical to write something like the following.

~~~
        devShells = rec {
          default = pkgs.mkShell {
            packages = [ (python.withPackages (ps: with ps; [ build ])) ];
          };
        };
~~~

Note that we need the parentheses to prevent `python.withPackages` and the argument
from being processed as two separate tokens.
Suppose we wanted to work with `virtualenv` and `pip` instead of `build`.
We could write something like the following.

~~~
        devShells = rec {
          default = pkgs.mkShell {
            packages = [
              # Python plus helper tools
              (python.withPackages (ps: with ps; [
                virtualenv # Virtualenv
                pip # The pip installer
              ]))
            ];
          };
        };
~~~

For the package builder, we can use the `buildPythonApplication` function.

~~~
        packages = rec {
          hello = python.pkgs.buildPythonApplication {
            name = "hello-flake-python";
            buildInputs = with python.pkgs; [ pip ];
            src = ./.;
          };
          default = hello;
        };
~~~

If you put all the pieces together, your `flake.nix` should look something like this.

~~~
$# curl https://codeberg.org/mhwombat/hello-flake-python/raw/branch/main/flake.nix --silent --output flake.nix
$ cat flake.nix
~~~

Let's try out the new flake.

~~~
$ nix run
~~~

Why can't it find `flake.nix`?
Nix flakes only "see" files that are part of the repository.
We need to add all of the important files to the repo before building or running the flake.

~~~
$ git add flake.nix setup.py hello.py
$ nix run
~~~

We'd like to share this package with others, but first we should do some cleanup.
When the package was built (automatically by the `nix run` command),
it created a `flake.lock` file.
We need to add this to the repo, and commit all important files.

~~~
$ git add flake.lock
$ git commit -a -m 'initial commit'
~~~

You can test that your package is properly configured by going to another directory and running it from there.

~~~
$ cd ~
$ nix run ~/tutorial-practice/hello-python
~~~

If you move the project to a public repo, anyone can run it.
Recall from the beginning of the tutorial that you were able to run `hello-flake` directly from my repo
with the following command.

~~~
nix run "git+https://codeberg.org/mhwombat/hello-flake"
~~~

Modify the URL accordingly and invite someone else to run your new Python flake.
