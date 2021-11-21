# Re-use a NixOS Derivation outside of Nix

## The scenario

You're running NixOS.
You want to do some development work on a project that uses a build
system other than Nix.
If you only use that build system for this one project,
you may not want to install all of the tools it requires in NixOS.
Instead, it would be nice to set up a nix shell that has those tools.

If you're not familiar with the build system, writing a Nix derivation
may seem a daunting task.
However, there is a package in NixOS for this project,
so someone must have written a derivation.
Perhaps you can use that?

## Finding the derivation

First, we need to find that derivation.
Go to https://github.com/NixOS/nixpkgs
and click on the "Go to File" button near the top of the page.
This activates the file finder.
Type the name of the package.
You're looking for something like:

    pkgs/blah/blah/package-name/default.nix

For example, the derivation for the `curl` package is

    pkgs/tools/networking/curl/default.nix

That directory may contain other files such as patches and scripts.
If you only want a Nix *shell*
(once you're in it you'll use the tools for that project's build system),
the `default.nix` file is probably all you need.
Copy that to the root directory of your project.

Some packages, such `emacs` or `python3` have more complicated set-ups.
These instructions assume you're dealing with a simpler package.

## A slight wrinkle

If you try to enter a nix shell using the `default.nix` you got from
NixOS/nixplkgs, you'll get an error message similar to this:

    $ nix-shell
    error: cannot evaluate a function that has an argument without a value ('lib')

           Nix attempted to evaluate a function as a top level expression; in
           this case it must have its arguments supplied either by default
           values, or passed explicitly with '--arg' or '--argstr'. See
           https://nixos.org/manual/nix/stable/#ss-functions.

           at /home/amy/waybar-amy/default.nix:1:3:

                1| { lib
                 |   ^
                2| , stdenv

The problem is that this derivation was written to be used as part of a
NixOS build, and it expects certain arguments to be supplied.

## The solution

We can easily create a `shell.nix` that will inject all of the
dependencies that `default.nix` expects.
Here's what to put in it:

    let
      pkgs = import <nixpkgs> {};
    in
    pkgs.callPackage ./default.nix {}


Now the `nix-shell` command should work as expected.

## Want to know more?

The code above is a simplified version of how
`pkgs/top-level/all-packages.nix` invokes the `default.nix`es for
each package in NixOS.
Youll find it
[here](https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/all-packages.nix).
This is a good file to become acquainted with if you want to
contribute to NixOS.

## Acknowledgements

*Thank you to jtojnar on the Nix Discourse forum for this elegant
solution!*
