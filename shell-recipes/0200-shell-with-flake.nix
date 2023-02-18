# ## Shell with access to a flake
#
with (import <nixpkgs> {});
let
   hello = (builtins.getFlake git+https://codeberg.org/mhwombat/hello-flake).packages.${builtins.currentSystem}.default;
   # For older flakes, you might need an expression like this...
   # hello = (builtins.getFlake git+https://codeberg.org/mhwombat/hello-flake).defaultPackage.${builtins.currentSystem};
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
