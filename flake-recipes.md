# Nix flake recipes

Each repository listed below is intended to be a minimal, self-contained example demonstrating one aspect of flakes.

- The [hello-flake](https://codeberg.org/mhwombat/hello-flake) repo
  shows how to package a Bash script.

- The [hello-flake-compat](https://codeberg.org/mhwombat/hello-flake-compat) repo
  is identical to `hello-flake`, except that it can be used in legacy (non-flake) projects.
  This allows us to launch a shell using either the old nix-shell or the new nix shell commands,
  and to build the project using either the old nix-build or the new nix build commands.

- The [hello-flake-haskell](https://codeberg.org/mhwombat/hello-flake-haskell) repo
  shows how to package a Haskell program.
