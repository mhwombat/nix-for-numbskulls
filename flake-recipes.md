# Nix flake recipes

The [hello-flake](https://codeberg.org/mhwombat/hello-flake) repo
is a very simple nix flake.
This package contains a single executable bash script that prints a greeting.

The [hello-flake-compat](https://codeberg.org/mhwombat/hello-flake-compat) repo
is identical to `hello-flake`, except that it can be used in legacy (non-flake) projects.
This allows us to launch a shell using either the old nix-shell or the new nix shell commands,
and to build the project using either the old nix-build or the new nix build commands.

The [hello-flake-haskell](https://codeberg.org/mhwombat/hello-flake-haskell) repo
is another simple nix flake.
This package contains a single executable Haskell program that prints a greeting.
