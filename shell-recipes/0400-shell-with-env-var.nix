# ## Shell with an environment variable set
#
# This shell has the environment variable FOO set to "bar"
#
with (import <nixpkgs> {});
mkShell {
  shellHook = ''
    export FOO="bar"
  '';
}
# Here's a demonstration using the shell.
#
#     $ nix-shell
#     $ echo $FOO
#     bar
#
