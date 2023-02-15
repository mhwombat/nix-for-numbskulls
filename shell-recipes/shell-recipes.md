# Nix shell recipes

*Tip:* Click the ![](menu-icon.png "menu icon")
menu icon in the file header to see the table of contents and go directly to the recipe you're interested in.
<!-- 0100-shell-with-nixpkgs.nix -->
## Shell with access to a package from the Nixpkgs/NixOS repo

This shell provides access to two packages from nixpkgs: hello and cowsay.

    with (import <nixpkgs> {});
    mkShell {
      buildInputs = [
        hello
        cowsay
      ];
    }
Here's a demonstration using the shell.

    $ nix-shell
    $ hello
    Hello, world!
    $ cowsay "moo"
     _____
    < moo >
     -----
            \   ^__^
             \  (oo)\_______
                (__)\       )\/\
                    ||----w |
                    ||     ||

The command-line equivalent would be `nix-shell -p hello cowsay`


<!-- 0150-shell-with-git-nix-pkg.nix -->
## Shell with access to a package defined in a remote git repo

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
Here's a demonstration using the shell.

   $ nix-shell
   $ hello-nix
   Hello from your nix package!

<!-- 0200-shell-haskell-local.nix -->
## Shell with access to a Haskell package on your local computer

This shell provides access to three Haskell packages that are on my hard drive.

    with (import <nixpkgs> {});
    let
      pandoc-linear-table = haskellPackages.callCabal2nix "pandoc-linear-table" /home/amy/github/pandoc-linear-table {};
      pandoc-logic-proof = haskellPackages.callCabal2nix "pandoc-logic-proof" /home/amy/github/pandoc-logic-proof {};
      pandoc-columns = haskellPackages.callCabal2nix "pandoc-columns" /home/amy/github/pandoc-columns {};
    in
    mkShell {
      buildInputs = [
                      pandoc
                      pandoc-linear-table
                      pandoc-logic-proof
                      pandoc-columns
                    ];
    }

<!-- 0300-shell-haskell-local-deps.nix -->
## Shell with access to a Haskell package on your local computer, with interdependencies

This shell provides access to four Haskell packages that are on my hard drive.
The fourth package depends on the first three to build.

    with (import <nixpkgs> {});
    let
      pandoc-linear-table = haskellPackages.callCabal2nix "pandoc-linear-table" /home/amy/github/pandoc-linear-table {};
      pandoc-logic-proof = haskellPackages.callCabal2nix "pandoc-logic-proof" /home/amy/github/pandoc-logic-proof {};
      pandoc-columns = haskellPackages.callCabal2nix "pandoc-columns" /home/amy/github/pandoc-columns {};
      pandoc-maths-web = haskellPackages.callCabal2nix "pandoc-maths-web" /home/amy/github/pandoc-maths-web
                           {
                             inherit pandoc-linear-table pandoc-logic-proof pandoc-columns;
                           };
    in
    mkShell {
      buildInputs = [
                      pandoc
                      pandoc-linear-table
                      pandoc-logic-proof
                      pandoc-columns
                      pandoc-maths-web
                    ];
    }

