# Quickstart Guide to Flakes

When I first encountered flakes they seemed quite complex and scary.
Most of the flake examples I found had so many levels of indentation
they made my brain wobble.
I even had difficulty understanding the templates and trying
to figure out what "type" of thing
(e.g. string, attribute set, derivation) I was supposed to put where.

In this guide I focus on things that you need to know as a beginner,
directing you where to go for more information on each particular topic.
I've also included a list of other resources,
some of which (at the time I write this) aren't as well-known.

# Templates

You don't have to write flakes from scratch, there are several
templates you can use.
To see the available templates:

```
nix flake show templates
```

To create a flake from a specific template:

```
nix flake init -t templates#simpleContainer
```

# Flake structure

The basic structure of a flake is

```
{
  description = ... # package description
  inputs = ... # dependencies
  outputs = ... # what the flake produces
  nixConfig = ... # advanced configuration options
}
```

The `description` part is self-explanatory.
You probably won't need `nixConfig` unless you're doing something fancy.
I'm going to focus on what goes into the `inputs` and `outputs` sections,
and highlight some of the things I found confusing.

# Inputs

This section specifies the dependencies of a flake.

To ensure that a build is reproducible, the build step runs in a *pure* environment,
with no access to anything except files that are part of its repo.
Therefore, any external dependencies must be specified in the "inputs" section
so they can be fetched in advance (before we enter the pure environment).

Each entry in this section maps an input name to a *flake reference*.
This commonly takes the following form.

```
NAME.url = URL-LIKE-EXPRESSION
```

As a first example, all (almost all?) flakes depend on "nixpkgs",
which is a large Git repository of programs and libraries
that are pre-packaged for Nix.
We can write that as

```
nixpkgs.url = "github:NixOS/nixpkgs/nixos-VERSION";
```

where `NN.MM` is replaced with the version number that you used to build the package, e.g. `22.11`.
Information about the latest nixpkgs releases is available at https://status.nixos.org/.
You can also write the entry without the version number

```
nixpkgs.url = "github:NixOS/nixpkgs/nixos-VERSION";
```

or more simply,

```
nixpkgs.url = "nixpkgs";
```

You might be concerned that omitting the version number would make the build non-reproducible.
If someone else builds the flake, could they end up with a different version of nixpkgs?
No! When you lock the flake (using `nix flake lock`), it creates a lockfile which *uniquely* specifies
all flake inputs, including version number, branch, revision, hash, etc., as needed.

Git and Mercurial repositories are the most common type of flake reference, as in the examples below.

- `git+https://github.com/NixOS/patchelf`: A Git repository.
- `git+https://github.com/NixOS/patchelf?ref=master`: A specific branch of a Git repository.
- `git+https://github.com/NixOS/patchelf?ref=master&rev=f34751b88bd07d7f44f5cd3200fb4122bf916c7e`: A specific branch and revision of a Git repository.
- `https://github.com/NixOS/patchelf/archive/master.tar.gz`: A tarball flake.

You can find more examples of flake references in the [Nix Reference Manual](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#examples).

Although you probably won't need to use it, there is another syntax for flake references that you might encounter.
This example

```
inputs.import-cargo = {
  type = "github";
  owner = "edolstra";
  repo = "import-cargo";
};
```

is equivalent to

```
inputs.import-cargo.url = "github:edolstra/import-cargo";
```

Each of the `inputs` is fetched, evaluated and passed to the `outputs`
function as a set of attributes with the same name as the
corresponding input.

# Outputs

This section is a function that essentially returns the recipe for building the flake.

We said above that `inputs` are passed to the `outputs`,
so we need to list them as parameters.
This example references the `import-cargo` dependency defined
in the previous example.

```
outputs = { self, nixpkgs, import-cargo }: {
  ... outputs ...
};
```

So what actually goes in this section (where I wrote `...outputs...`)?
That depends on the programming languages your software is written in,
the build system you use, and more.
There are Nix functions and tools that can simplify much of this,
and new, easier-to-use ones are released regularly.
I recommend that you start by consulting some of the resources below,
and find a simple example of a flake written for your programming language and chosen build system.
I've started a small [collection of examples](flake-recipes.md) that may be helpful.

# Other resources

- [Zero to Nix](https://zero-to-nix.com/start/install) is a Nix tutorial that focuses on flakes
- [The nix flake section of the Nix manual](https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html)
- [Nix flake recipes](flake-recipes.md)

The following resources are a bit older, may not reflect the latest flake information, and not quite as beginner-friendly.
However, they are valuable when you want a deeper understanding.

- [This nix flake page in the wiki](https://nixos.wiki/wiki/Flakes)
- [Eelco Dolstra's tutorial, part 1](https://www.tweag.io/blog/2020-05-25-flakes/)
- [Eelco Dolstra's tutorial, part 2](https://www.tweag.io/blog/2020-06-25-eval-cache/)
- [Eelco Dolstra's tutorial, part 3](https://www.tweag.io/blog/2020-07-31-nixos-flakes/)
- [Xe Iaso's blog post](https://christine.website/blog/nix-flakes-1-2022-02-21)
- [zimbatm's post](https://zimbatm.com/notes/nixflakes)
- [y|sndr's blog post](https://blog.ysndr.de/posts/internals/2021-01-01-flake-ification/)
- [Bantyev's blog post on serokell.io](https://serokell.io/blog/practical-nix-flakes)
