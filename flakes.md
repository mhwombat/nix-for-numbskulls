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
Each entry maps an input name to a *flake reference*.
The most common type of flake reference is a
Git or Mercurial repositories.
Here's a simple example:

```
inputs.import-cargo = {
  type = "github";
  owner = "edolstra";
  repo = "import-cargo";
};
```

Equivalently, you could just write:

```
inputs.import-cargo.url = "github:edolstra/import-cargo";
```

A directory containing a flake can also be an input:

```
inputs.grid.url = "path:/home/amy/github/grid";
```

See the [Nix documentation](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#flake-inputs) for more options.

Each of the `inputs` is fetched, evaluated and passed to the `outputs`
function as a set of attributes with the same name as the
corresponding input.

# Outputs

We said above that `inputs` are passed to the `outputs`,
so we need to list them as parameters.
This example references the `import-cargo` dependency defined
in the previous example.

```
outputs = { self, nixpkgs, import-cargo }: {
  ... outputs ...
};
```

Below, I discuss the most common elements in the outputs section .
For information on other things that can go here,
see the [wiki](https://nixos.wiki/wiki/Flakes).


## Build instructions

`packages."<system>"."<name>" = derivation;`

This is where you specify how to build the binary package for
whatever system types you support.
`<system>` is something like "x86_64-linux", "aarch64-linux", "i686-linux", or "x86_64-darwin".
This is executed by `nix build .#<name>`

## The default package

If your flake provides only one package, or there is a clear "main"
package, include this:

`defaultPackage."<system>" = derivation;`

`<system>` is something like "x86_64-linux", "aarch64-linux", "i686-linux", or "x86_64-darwin".
This executed by `nix build .`

## NixOS modules

If you want to be able to use your flake as a NixOS module,
include this:

`nixosModules = {};`

This is used by `nixos-rebuild --flake .#<hostname>`
`nixosConfigurations."<hostname>".config.system.build.toplevel`

## Overlays

`overlay = final: prev: { };`

This is a default overlay that can be consumed by other flakes.


# Other resources

- [This nix flake page in the wiki](https://nixos.wiki/wiki/Flakes)
- [The nix flake section of the Nix manual](https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html)
- [Eelco Dolstra's tutorial, part 1](https://www.tweag.io/blog/2020-05-25-flakes/)
- [Eelco Dolstra's tutorial, part 2](https://www.tweag.io/blog/2020-06-25-eval-cache/)
- [Eelco Dolstra's tutorial, part 3](https://www.tweag.io/blog/2020-07-31-nixos-flakes/)
- [Xe Iaso's blog post](https://christine.website/blog/nix-flakes-1-2022-02-21)
- [zimbatm's post](https://zimbatm.com/notes/nixflakes)
- [y|sndr's blog post](https://blog.ysndr.de/posts/internals/2021-01-01-flake-ification/)
- [Bantyev's blog post on serokell.io](https://serokell.io/blog/practical-nix-flakes)
