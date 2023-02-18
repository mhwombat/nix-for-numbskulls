# ## Shell with access to a specific revision of a flake
#
with (import <nixpkgs> {});
let
   hello = (builtins.getFlake git+https://codeberg.org/mhwombat/hello-flake?ref=main&rev=3aa43dbe7be878dde7b2bdcbe992fe1705da3150).packages.${builtins.currentSystem}.default;
in
mkShell {
  buildInputs = [
    hello
  ];
}
# Here's a demonstration using the shell.
#
#     $ nix-shell
#     $ hello-flake
#     Hello from your flake!
