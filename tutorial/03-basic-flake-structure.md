# Flake structure

The basic structure of a flake is shown below.

~~~
{
  description = ... # package description
  inputs = ... # dependencies
  outputs = ... # what the flake produces
  nixConfig = ... # advanced configuration options
}
~~~

The `description` part is self-explanatory; it's just a string.
You probably won't need `nixConfig` unless you're doing something fancy.
I'm going to focus on what goes into the `inputs` and `outputs` sections,
and highlight some of the things I found confusing.

## Inputs

This section specifies the dependencies of a flake.
It's an *attribute set*; it maps keys to values.

To ensure that a build is reproducible, the build step runs in a *pure* environment,
with no access to anything except files that are part of its repo.
Therefore, any external dependencies must be specified in the "inputs" section
so they can be fetched in advance (before we enter the pure environment).

Each entry in this section maps an input name to a *flake reference*.
This commonly takes the following form.

~~~
NAME.url = URL-LIKE-EXPRESSION
~~~

As a first example, all (almost all?) flakes depend on "nixpkgs",
which is a large Git repository of programs and libraries
that are pre-packaged for Nix.
We can write that as

~~~
nixpkgs.url = "github:NixOS/nixpkgs/nixos-VERSION";
~~~

where `NN.MM` is replaced with the version number that you used to build the package, e.g. `22.11`.
Information about the latest nixpkgs releases is available at https://status.nixos.org/.
You can also write the entry without the version number

~~~
nixpkgs.url = "github:NixOS/nixpkgs/nixos-VERSION";
~~~

or more simply,

~~~
nixpkgs.url = "nixpkgs";
~~~

You might be concerned that omitting the version number would make the build non-reproducible.
If someone else builds the flake, could they end up with a different version of nixpkgs?
No! remember that the lockfile (`flake.lock`) *uniquely* specifies
all flake inputs.

Git and Mercurial repositories are the most common type of flake reference, as in the examples below.

A Git repository
 : `git+https://github.com/NixOS/patchelf`
  :

A specific branch of a Git repository
  : `git+https://github.com/NixOS/patchelf?ref=master`

A specific branch and revision of a Git repository
  : `git+https://github.com/NixOS/patchelf?ref=master&rev=f34751b88bd07d7f44f5cd3200fb4122bf916c7e`

A tarball
  : `https://github.com/NixOS/patchelf/archive/master.tar.gz`

You can find more examples of flake references in the [Nix Reference Manual](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#examples).

Although you probably won't need to use it, there is another syntax for flake references that you might encounter.
This example

~~~
inputs.import-cargo = {
  type = "github";
  owner = "edolstra";
  repo = "import-cargo";
};
~~~

is equivalent to

~~~
inputs.import-cargo.url = "github:edolstra/import-cargo";
~~~

Each of the `inputs` is fetched, evaluated and passed to the `outputs`
function as a set of attributes with the same name as the
corresponding input.

## Outputs

This section is a function that essentially returns the recipe for building the flake.

We said above that `inputs` are passed to the `outputs`,
so we need to list them as parameters.
This example references the `import-cargo` dependency defined
in the previous example.

~~~
outputs = { self, nixpkgs, import-cargo }: {
  ... outputs ...
};
~~~

So what actually goes in this section (where I wrote `...outputs...`)?
That depends on the programming languages your software is written in,
the build system you use, and more.
There are Nix functions and tools that can simplify much of this,
and new, easier-to-use ones are released regularly.
We'll look at some of these in the next section.
