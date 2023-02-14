# This shell provides access to two packages from nixpkgs: hello and cowsay.
# Here's a demonstration.
#
#    $ nix-shell shell-with-nixpkgs.nix
#    $ hello
#    Hello, world!
#    $ cowsay "moo"
#     _____
#    < moo >
#     -----
#            \   ^__^
#             \  (oo)\_______
#                (__)\       )\/\
#                    ||----w |
#                    ||     ||
#
# The command-line equivalent would be `nix-shell -p hello cowsay`
#
with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    hello
    cowsay
  ];
}
