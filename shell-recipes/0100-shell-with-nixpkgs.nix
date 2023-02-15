# ## Shell with access to a package from the Nixpkgs/NixOS repo
#
# This shell provides access to two packages from nixpkgs: hello and cowsay.
#
with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    hello
    cowsay
  ];
}
# Here's a demonstration using the shell.
#
#     $ nix-shell
#     $ hello
#     Hello, world!
#     $ cowsay "moo"
#      _____
#     < moo >
#      -----
#             \   ^__^
#              \  (oo)\_______
#                 (__)\       )\/\
#                     ||----w |
#                     ||     ||
#
# The command-line equivalent would be `nix-shell -p hello cowsay`
#
