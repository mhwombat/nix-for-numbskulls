# Nix flake recipes

Also see the [Quickstart Guide to Flakes](https://github.com/mhwombat/nix-for-numbskulls/blob/main/flakes.md).

## A generic flake template

<pre>{
  description = &quot;<var>BRIEF PACKAGE DESCRIPTION</var>&quot;;
&nbsp;
  inputs = {
    nixpkgs.url = &quot;github:NixOS/nixpkgs&quot;;
    flake-utils.url = &quot;github:numtide/flake-utils&quot;;
    <var>...FLAKE REFERENCES FOR OTHER DEPENDENCIES...</var>
  };
&nbsp;
  outputs = { self, nixpkgs, flake-utils, <var>...OTHER DEPENDENCIES...</var> }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python3;
      in
      {
        devShells = rec {
          default = <var>DEFINITION FOR DEVELOPMENT SHELL</var>;
        };
&nbsp;
        packages = rec {
          <var>myPackageName</var> = <var>PACKAGE DEFINITION</var>;
          default = <var>myPackageName</var>;
        };
&nbsp;
        apps = rec {
          <var>myPackageName</var> = flake-utils.lib.mkApp { drv = self.packages.${system}.<var>myPackageName</var>; };
          default = <var>myPackageName</var>;
        };
      }
    );
}</pre>

### A typical development shell

<pre>        devShells = rec {
          default = pkgs.mkShell {
            packages = [
              <var>LIST OF PACKAGES YOU WANT ACCESS TO FOR DEVELOPMENT</var>
            ];
          };
        };</pre>

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
