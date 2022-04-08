# Quickstart guide to stdenv.mkDerivation

The function mkDerivation in the Nixpkgs standard environment is a wrapper around derivation that adds a default value for system and always uses Bash as the builder, to which the supplied builder is passed as a command-line argument.

The [nix manual](https://nixos.org/manual/nix/stable/expressions/derivations.html)
has a good discussion on the environment available to a derivation
at the time it's being realised (built).

The set of commands available is documented in the [nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/#sec-tools-of-stdenv).
