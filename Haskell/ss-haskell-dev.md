# Super-Simple Haskell Development with Nix

## My goals

I have struggled to find a comfortable way to develop Haskell in a NixOS
(or nix) environment.
I read the excellent [Nix Pills](https://nixos.org/guides/nix-pills/),
and developing shell scripts or C code seemed pretty straightforward,
but it wasn't obvious to me how to extend that knowledge to Haskell.
I read lots of Haskell+Nix tutorials, but the Nix derivations they
suggested were complex, and it was difficult for me to diagnose any
problems I encountered.

Another source of confusion is that the Nix derivations recommended by
different tutorials were usually completely different.
One reason for this is that Nix has added better tools for Haskell
development (e.g. `pkgs.haskellPackages.developPackage`), and Cabal has
made changes that make it more Nix-like.
So newer tutorials can use simpler derivations.

And yet, many tutorials suggest using additional build tools such as
niv, binary caches, flakes, or Stack.
I wanted to minimise the number of technologies involved in the
development process.
In recent years, Cabal has added some very nice features that -- for the
type of projects I work on -- make Stack or other build tools
unnecessary.
The more technologies are involved in the process, the more complicated
it is to diagnose any problems that occur.
*Even if I eventually decide to introduce some of these tools to my
workflow, I wanted to get more comfortable with Nix first.*

## The basic workflow

1. To bootstrap a brand new project, run this command to create a cabal
file.
If you already have a cabal file, you can skip this step.

    nix-shell --packages ghc --run 'cabal init'

2. Create default.nix:

```
let
  pkgs = import <nixpkgs> { };
in
  pkgs.haskellPackages.developPackage {
    root = ./.;
  }
```

*Important:* Your directory must have the same name as your package,
or else you have to set the "name" field in `default.nix`.

3. Build your package in one of two ways:

   - Run `nix-build`.
   - Run `nix-shell` to enter an environment with all of your
     dependencies available, and then use the usual cabal commands.

## Adding or overriding dependencies

If you need a package that isn't in Hackage, or you want to use a
different version, add it to `default.nix`.
In the example below, I've added the path to another package named
`additional-package`.

```
let
  pkgs = import <nixpkgs> { };
in
  pkgs.haskellPackages.developPackage {
    root = ./.;
    source-overrides = {
      additional-package = ../additional-package;
    };
  }
```

## What about cabal.project?

The file `default.nix` specifies the package versions that will
be available (installed) when you enter the shell.
You can also use `cabal.project` to specify where to find packages that
you want to install (or rebuild and re-install) while you're in the
shell.
The difference is subtle, and you may end up listing packages in
both files.
Also, you can end up with two versions of a package installed in your
development environment;
one by Nix (because it was listed in `default.nix`)
and another by `cabal-install` (because it was listed in
`cabal.project`).
This usually causes no harm, but it can be a little confusing.

*I find it simpler to just use `default.nix`,
and not have a `cabal.project` file.*
If I need to rebuild one of my package's dependencies, I simply exit the
shell and re-enter it.
Any packages listed in `default.nix` will automatically be rebuilt as
needed.

## Create an executable haskell script

Add something like this to the top of your Haskell source file.
In the example below, I have a dependency on a package called `pandoc`.

```
#! /usr/bin/env nix-shell
#! nix-shell -p "haskellPackages.ghcWithPackages (p: [p.pandoc])"
#! nix-shell -i runghc
```

Make the file executable, and run it as usual (`./something.hs`).
