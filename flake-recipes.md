# Nix flake recipes

Also see the [Quickstart Guide to Flakes](https://github.com/mhwombat/nix-for-numbskulls/blob/main/flakes.md).

You may find this colour-coded
[generic flake template](https://mhwombat.codeberg.page/nix-book/#_a_generic_flake)
with instructions helpful.

Each repository listed below is intended to be a minimal, self-contained example demonstrating one aspect of flakes.

- The [hello-flake](https://codeberg.org/mhwombat/hello-flake) repo
  shows how to package a Bash script.

- The [hello-flake-compat](https://codeberg.org/mhwombat/hello-flake-compat) repo
  is identical to `hello-flake`, except that it can be used in legacy (non-flake) projects.
  This allows us to launch a shell using either the old `nix-shell`
  or the new `nix shell` (no hyphen) commands,
  and to build the project using either the old `nix-build` or the new `nix build` commands.

- The [hello-flake-haskell](https://codeberg.org/mhwombat/hello-flake-haskell) repo
  shows how to package a Haskell program.

- The [hello-flake-python](https://codeberg.org/mhwombat/hello-flake-python) repo
  shows how to package a Python program.
