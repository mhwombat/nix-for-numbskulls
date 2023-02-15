# ## Shell with access to a package defined in a remote git repo
#
with (import <nixpkgs> {});
let
  hello = import (builtins.fetchGit {
                                           url = "https://codeberg.org/mhwombat/hello-nix";
                                           rev = "aa2c87f8b89578b069b09fdb2be30a0c9d8a77d8";
                                         });
in
mkShell {
  buildInputs = [ hello ];
}
# Here's a demonstration using the shell.
#
#    $ nix-shell
#    $ hello-nix
#    Hello from your nix package!
