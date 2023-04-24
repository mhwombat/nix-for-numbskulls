# A new flake from scratch (Python)

At last we are ready to create a flake from scratch!
Start with an empty directory and create a git repository.

~~~
$ cd ~/tutorial-practice
$ mkdir hello-python
$ cd hello-python
$ git init
~~~

Create a simple Python program.

~~~
$# curl https://codeberg.org/mhwombat/hello-flake-python/raw/branch/main/hello.py --silent --output hello.py
$ cat hello.py
~~~

Create a Python script to build the package.

~~~
$# curl https://codeberg.org/mhwombat/hello-flake-python/raw/branch/main/setup.py --silent --output setup.py
$ cat setup.py
~~~

Create the Nix flake definition.

~~~
$# curl https://codeberg.org/mhwombat/hello-flake-python/raw/branch/main/flake.nix --silent --output flake.nix
$ cat flake.nix
~~~

TBD

EXPLAIN THAT FILES ARE INVISIBLE TO FLAKES UNTIL THEY ARE ADDED TO THE GIT REPO!!!!!
