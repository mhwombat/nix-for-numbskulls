# The Nix Function Zoo

It's not always easy to find information on some of the commonly-used Nix functions,
particularly the Haskell-related ones,
so I've included some links below.
Thanks go to cdpillabout for much of this information.
There's a lot more good information in this [Discourse thread](https://discourse.nixos.org/t/why-are-these-derivations-so-different/18257/3),
I've only summarised part of it below.
More to come as I continue to learn.

# `stdenv.mkDerivation`

A wrapper around `derivation` that adds a default value for system 
and always uses Bash as the builder, to which the supplied builder 
is passed as a command-line argument.

The [nix manual](https://nixos.org/manual/nix/stable/expressions/derivations.html)
has a good discussion on the environment available to a derivation
at the time it's being realised (built).

The set of commands available is documented in the [nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/#sec-tools-of-stdenv).

# `std.callPackage`

A convenience function that imports and calls a function, filling in any 
missing arguments by passing the corresponding attribute from the Nixpkgs set.

The [Nix manual](https://nixos.org/manual/nix/stable/expressions/arguments-variables.html?highlight=callPackage#arguments-and-variables)
provides documentation.

There's also a [Nix pill](https://nixos.org/guides/nix-pills/callpackage-design-pattern.html)
that shows how to write and use your own version of this function.

# `haskellPackages.mkDerivation`

Don't confuse with `stdenv.mkDerivation`!

This is effectively a wrapper around `std.mkDerivation`.

Defined in [make-package-set.nix](https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/haskell-modules/make-package-set.nix)

# `haskellPackages.developPackage`

A function for easily doing Haskell development on a local package.
This function is documented in the code; I've summarised it below.

Parameters
- `root` path to a haskell package directory
- `name` optional package name. Defaults to base name of the path.
- `source-overrides` optional source overrides, Either Path VersionNumber
- `overrides` optional arbitrary overrides, HaskellPackageOverrideSet
- `modifier` optional Haskell package modifier
- `returnShellEnv` optional, if `true` this returns a derivation which will give you
  an environment suitable for developing the listed packages with an
  incremental tool like cabal-install.
- `withHoogle` optional, if true (the default if a shell environment is requested)
  then 'ghcWithHoogle' is used to generate the derivation (instead of
  'ghcWithPackages'), see the documentation there for more information.
- 'cabal2nixOptions' optional, can contain extra command line arguments to pass to
  'cabal2nix' when generating the package derivation, for example setting
  a cabal flag with '--flag=myflag'.
    
Defined in [make-package-set.nix](https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/haskell-modules/make-package-set.nix)

# `haskellPackages.callPackage`

Similar to the top-level `callPackage`, but it knows about all the Haskell packages in the Nixpkgs Haskell package set.
It also knows to fall back to looking for packages in the top-level Nixpkgs for things that aren’t Haskell libraries. 
So things like fetchgit, lib, etc will be pulled from the top-level Nixpkgs.

Defined in [make-package-set.nix](https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/haskell-modules/make-package-set.nix)

# `cabal2nix`

Not a function, but an executable program.
Reads a `.cabal` file and produces a function call.
You run it, redirect output to a file on disk, then call `haskellPackages.callPackage` on that output.
(Compare with `haskellPackage.callCabal2nix`.)

Documentation available from `cabal2nix --help`.

# `haskellPackage.callCabal2nix`

As the name suggests, this effectively calls `cabal2nix` so you don't have to.

Defined in [make-package-set.nix](https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/haskell-modules/make-package-set.nix)

# `haskellPackages.shellfor`

For creating a development environment that contains multiple Haskell packages. 
This is useful when you’re working on a “big” Haskell project, where you have a bunch of individual Haskell packages.
In general, you’d define each of your individual packages with callCabal2nix, and then pass them all to `shellFor`. 
This function is documented in the [make-package-set.nix](https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/haskell-modules/make-package-set.nix);
the comments include an example of how to use it.

Defined in [make-package-set.nix](https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/haskell-modules/make-package-set.nix)

# Other functions

There's a list of other functions in the [NixOS manual](https://nixos.org/manual/nixpkgs/stable/#chap-functions)
with some brief documentation.
