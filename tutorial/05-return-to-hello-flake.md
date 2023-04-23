# Another look at hello-flake

Now that we have a better understanding of the structure of `flake.nix`,
let's have a look at the one we saw earlier, in the `hello-flake` repo.
If you compare this flake definition to the colour-coded template
presented in the previous section, most of it should look familiar.

~~~
{
  description = "a very simple and friendly flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = rec {
          hello =
            . . .
            SOME UNFAMILIAR STUFF
            . . .
          };
          default = hello;
        };

        apps = rec {
          hello = flake-utils.lib.mkApp { drv = self.packages.${system}.hello; };
          default = hello;
        };
      }
    );
}
~~~

This `flake.nix` doesn't have a `devShells` section, because development on the current version
doesn't require anything beyond the "bare bones" linux commands.
Later we will add a feature that requires additional development tools.

Now let's look at the section I labeled "`SOME UNFAMILIAR STUFF`"
and see what it does.

~~~
        packages = rec {
          hello = pkgs.stdenv.mkDerivation rec { ❶
            name = "hello-flake";

            src = ./.; ❷

            unpackPhase = "true";

            buildPhase = ":";

            installPhase =
              ''
                mkdir -p $out/bin ❸
                cp $src/hello-flake $out/bin/hello-flake ❹
                chmod +x $out/bin/hello-flake ❺
              '';
          };
~~~

This flake uses `mkDerivation`, ❶ which is a very useful general-purpose package builder
provided by the Nix standard environment.
It's especially useful for the typical `./configure; make; make install` scenario,
but for this flake we don't even need that.

The `name` variable is the name of the flake, as it would appear in a package listing
if we were to add it to Nixpkgs or another package collection.
The `src` variable supplies the location of the source files, relative to `flake.nix`.
When a flake is accessed for the first time, the repository contents are fetched in the form of a tarball.
The `unpackPhase` variable indicates that we do want the tarball to be unpacked.

The `buildPhase` variable is a sequence of Linux commands to build the package.
Typically, building a package requires compiling the source code.
However, that's not required for a simple shell script.
So `buildPhase` consists of a single command, `:`, which is a no-op or "do nothing" command.

The `installPhase` variable is a sequence of Linux commands that will do the actual installation.
In this case, we create a directory ❸ for the installation,
copy the `hello-flake` script ❹ there,
and make the script executable ❺.
The environment variable `$src` refers to the source directory, which we specified earlier ❷.

Earlier we said that the build step runs in a pure environment to ensure that builds are reproducible.
This means no Internet access; indeed no access to any files outside the build directory.
During the build and install phases,
the only commands available are those provided by the Nix standard environment
and the external dependencies identified in the `inputs` section of the flake.

I've mentioned the Nix standard environment before, but I didn't explain what it is.
The standard environment, or `stdenv`, refers to the functionality that is available
during the build and install phases of a Nix package (or flake).
It includes the commands listed below[^nixpkgs-manual-stdenv].

- The GNU C Compiler, configured with C and C++ support.
- GNU coreutils (contains a few dozen standard Unix commands).
- GNU findutils (contains find).
- GNU diffutils (contains diff, cmp).
- GNU sed.
- GNU grep.
- GNU awk.
- GNU tar.
- gzip, bzip2 and xz.
- GNU Make.
- Bash.
- The patch command.
- On Linux, stdenv also includes the patchelf utility.

[^nixpkgs-manual-stdenv]: For more information on the standard environment,
  see the [Nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/#sec-tools-of-stdenv)

Only a few environment variables are available.
The most useful ones are listed below.

- `$name` is the package name.
- `$src` refers to the source directory.
- `$out` is the path to the location in the Nix store where the package will be added.
- `$system` is the system that the package is being built for.
- $PWD and $TMP both point to a temporary build directories

In particular, $HOME and $PATH point to nonexistent directories, so the build cannot rely on them.
