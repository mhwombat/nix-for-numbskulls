# Nix flake recipes

Also see the [Quickstart Guide to Flakes](https://github.com/mhwombat/nix-for-numbskulls/blob/main/flakes.md).

## A generic flake template

    {
      description = "BRIEF PACKAGE DESCRIPTION";

      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs";
        flake-utils.url = "github:numtide/flake-utils";
        FLAKE REFERENCES FOR OTHER DEPENDENCIES
      };

      outputs = { self, nixpkgs, flake-utils, OTHER DEPENDENCIES }:
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = import nixpkgs { inherit system; };
            python = pkgs.python3;
          in
          {
            devShells = rec {
              default = DEFINITION FOR DEVELOPMENT SHELL;
            };

            packages = rec {
              myPackageName = PACKAGE DEFINITION;
              default = myPackageName;
            };

            apps = rec {
              myPackageName = flake-utils.lib.mkApp { drv = self.packages.${system}.myPackageName; };
              default = myPackageName;
            };
          }
        );
    }

### A typical development shell

            devShells = rec {
              default = pkgs.mkShell {
                packages = [
                  LIST OF PACKAGES YOU WANT ACCESS TO FOR DEVELOPMENT
                ];
              };
            };

### The package definition

This part depends on the programming language and build tools you use.
Here are a few functions that are commonly used:

General-purpose: [`mkDerivation`](https://nixos.org/manual/nixpkgs/stable/#chap-stdenv)
Handles the standard `./configure; make; make install` scenario, customisable.

Python: `buildPythonApplication`, `buildPythonPackage`.

Haskell: `mkDerivation` (Haskell version, which is a wrapper around the standard environment version),
`developPackage`, `callCabal2Nix`.

## Examples

Each repository listed below is intended to be a minimal, self-contained example demonstrating one aspect of flakes.

- The [hello-flake](https://codeberg.org/mhwombat/hello-flake) repo
  shows how to package a Bash script.

- The [hello-flake-compat](https://codeberg.org/mhwombat/hello-flake-compat) repo
  is identical to `hello-flake`, except that it can be used in legacy (non-flake) projects.
  This allows us to launch a shell using either the old nix-shell or the new nix shell commands,
  and to build the project using either the old nix-build or the new nix build commands.

- The [hello-flake-haskell](https://codeberg.org/mhwombat/hello-flake-haskell) repo
  shows how to package a Haskell program.
