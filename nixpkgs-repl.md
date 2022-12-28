# Investigating Nix packages in the REPL

I'll demonstrate how to investigate a Nix package using the REPL.
This can be useful, for example,
if you want to debug a problem with package you've written,
or understand one of the packages in the Nix store.
I'll also demonstrate some common mistakes you might make in the process, and how to correct them.

## A simple derivation

We'll begin with what is probably the simplest package in the nixpkgs repo, "hello".
To follow along, download the file
[default.nix](https://raw.githubusercontent.com/NixOS/nixpkgs/f3d9f4623d2f370cbf98433981b1e4593a4e7a3c/pkgs/applications/misc/hello/default.nix)
for the "hello" package.

Let's start the REPL, import the derivation for "hello", and inspect it.

```
$ nix repl
Welcome to Nix 2.12.0. Type :? for help.

nix-repl> d = import ./default.nix

nix-repl> d
«lambda @ /home/amy/github/nixpkgs/pkgs/applications/misc/hello/default.nix:1:1»
```

That *seems* to have worked.
Let's try to build it.

```
nix-repl> :b d
error: expression does not evaluate to a derivation, so I can't build it
```

What went wrong?
If you examine the first few lines of `default.nix`, you'll see that it expects some input parameters,
namely the other packages that it uses to build or test the program.
Normally these would be supplied by nix when you invoke `nix-env -i hello`,
or by NixOS when if you include `hello` in your configuration.
Since we're trying to create the derivation in the REPL, we need to pass those parameters manually.
(In the next section, we'll see an easier way to do this that doesn't require typing in all the parameters.)

```
nix-repl>  d = import ./default.nix { callPackage=callPackage; lib=lib; stdenv=stdenv; fetchurl=fetchurl; nixos=nixos; testers=testers; hello=hello; }
error: undefined variable 'fetchurl'

       at «string»:1:83:

            1|  import ./default.nix { callPackage=callPackage; lib=lib; stdenv=stdenv; fetchurl=fetchurl; nixos=nixos; testers=testers; hello=hello; }
             |                                                                                   ^
```

We still have a problem.
The reason that `fetchurl` is undefined is that we haven't provided access to the nixpkgs environment.
Let's remedy that and try again.

```
nix-repl> :l <nixpkgs>
Added 17880 variables.

nix-repl>  d = import ./default.nix { callPackage=callPackage; lib=lib; stdenv=stdenv; fetchurl=fetchurl; nixos=nixos; testers=testers; hello=hello; }

nix-repl> d
«derivation /nix/store/71gi3wchkrh5mzjybcjaw2mfzynv5kw5-hello-2.12.drv»
```

This time we got a `derivation` instead of a `lambda`, so something has changed.
Let's try building it.

```
nix-repl> :b d

This derivation produced the following outputs:
  out -> /nix/store/zgzkg0rlb5ylyj998siidspxq4mb068c-hello-2.12
```

Success!
The package has been built and added to the Nix store.
We can exit the REPL and try it out.

```
✦ ❯ /nix/store/zgzkg0rlb5ylyj998siidspxq4mb068c-hello-2.12/bin/hello
Hello, world!
```

Back in the REPL, we can interact with the derivation to better understand how it works.
Let's get a list of the attributes.

```
nix-repl> builtins.attrNames d
[ "__ignoreNulls" "all" "args" "buildInputs" "builder" "cmakeFlags" "configureFlags" "depsBuildBuild" "depsBuildBuildPropagated" "depsBuildTarget" "depsBuildTargetPropagated" "depsHostHost" "depsHostHostPropagated" "depsTargetTarget" "depsTargetTargetPropagated" "doCheck" "doInstallCheck" "drvAttrs" "drvPath" "inputDerivation" "mesonFlags" "meta" "name" "nativeBuildInputs" "out" "outPath" "outputName" "outputs" "overrideAttrs" "passthru" "patches" "pname" "propagatedBuildInputs" "propagatedNativeBuildInputs" "src" "stdenv" "strictDeps" "system" "tests" "type" "userHook" "version" ]
```

Everything defined in `default.nix` appears in the list, along with the defaults defined in `stdenv.mkDerivation`.
We can examine the values of the attributes.

```
nix-repl> d.pname
"hello"

nix-repl> d.version
"2.12"
```

Those values were hard-coded in `default.nix`, so didn't learn much from that.
However, derivations in package definitions sometimes involve complex expressions,
and it can be useful to see how they were evaluated.
As a trivial example, the URL in the `src` attribute is an expression that depends on the `version` attribute.
We can double-check that it evaluated the way we would expect.

```
nix-repl> d.src.url
"mirror://gnu/hello/hello-2.12.tar.gz"
```

We can find out where a package has been, or will be, installed.

```
nix-repl> d.outPath
"/nix/store/zgzkg0rlb5ylyj998siidspxq4mb068c-hello-2.12"
```

## Using `callPackage`

In the previous section, we learned that we have to supply parameters to `default.nix` to get the derivation.

```
nix-repl>  d = import ./default.nix { callPackage=callPackage; lib=lib; stdenv=stdenv; fetchurl=fetchurl; nixos=nixos; testers=testers; hello=hello; }
```

Typing out all those parameter names is annoying.
Fortunately, there is an easier way.

Let's look at how nixpkgs handles things.
If you examine the nixpkgs repo, you'll find a file called [`all-packages.nix`](https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/all-packages.nix).
This file specifies how to import the derivation for each package in nixpkgs.
For the "hello" package, it has the following.

```
  hello = callPackage ../applications/misc/hello { };
```

The function `callPackage` will handle the import for us, supplying all of the parameters automatically.

```
nix-repl> d = callPackage ./default.nix {}

nix-repl> d
«derivation /nix/store/7vf0d0j7majv1ch1xymdylyql80cn5fp-hello-2.12.1.drv»
```

Don't forget to load `<nixpkgs>` first.
Also, don't forget the `{}` at the end of the line invoking `callPackage`.

Note that some packages do not use the standard `callPackage` function, so you'll need to check `all-packages.nix` to verify.
Some of the more common alternatives you'll see are
`python3Packages.callPackage` and `libsForQt5.callPackage`

## A more sophisticated derivation

If you'd like follow along with this part, download these expressions for this particular version of the Textadept package.

- [default.nix](https://github.com/NixOS/nixpkgs/blob/213cf26f5e77b176dad4f22ebc29e7880b8e8394/pkgs/applications/editors/textadept/default.nix)
- [deps.nix](https://github.com/NixOS/nixpkgs/blob/213cf26f5e77b176dad4f22ebc29e7880b8e8394/pkgs/applications/editors/textadept/deps.nix)

This section of `default.nix` intimidated me the first time I saw it.

```
  preConfigure =
    lib.concatStringsSep "\n" (lib.mapAttrsToList (name: params:
      "ln -s ${fetchurl params} $PWD/src/${name}"
    ) (import ./deps.nix)) + ''
    cd src
    make deps
  '';
```

I could see that it imported `deps.nix`, which looks like this.

```
{
  "scintilla524.tgz" = {
    url = "https://www.scintilla.org/scintilla524.tgz";
    sha256 = "sha256-Su8UiMmkOxcuBat2JWYEnhNdG5HKnV1fn1ClnJhazGY=";
  };
  "lexilla510.tgz" = {
    url = "https://www.scintilla.org/lexilla510.tgz";
    sha256 = "sha256-azWVJ0AFSYZxuFTPV73uwiVJZvNxcS/POnFtl6p/P9g=";
  };
  ...and so on
}
```

Let's evaluate that `preConfigure` definition in the REPL.

```
✦ ❯ nix repl
Welcome to Nix 2.12.0. Type :? for help.

nix-repl> :l <nixpkgs>
Added 17880 variables.

nix-repl> d = import ./default.nix { lib=lib; stdenv=stdenv; fetchFromGitHub=fetchFromGithub; fetchurl=fetchurl; gtk2=gtk2; glib=glib; pkg-config=pkg-config; unzip=unzip; ncurses=ncurses; zip=zip; }

nix-repl> d.preConfigure
"ln -s /nix/store/nx8yz5xzq103ypjr2qb6nrjxnr9rf78m-444af9ca8a73151dbf759e6676d1035af469f01a.zip $PWD/src/444af9ca8a73151dbf759e6676d1035af469f01a.zip\nln -s /nix/store/rx0pp07k04vny2wfbd33xcaqa444yn6m-475d8d43f3418590c28bd2fb07ee9229d1fa2d07.zip $PWD/src/475d8d43f3418590c28bd2fb07ee9229d1fa2d07.zip\nln -s /nix/store/2f6qaarwrnbcnrnrjxzjmqysrczs4rka-9088723504b19f8611b66c119933a4dc7939d7b8.zip $PWD/src/9088723504b19f8611b66c119933a4dc7939d7b8.zip\nln -s /nix/store/980bp9jpcjiflslfazf7b0i90qvz4nx9-cdk-5.0-20200923.tgz $PWD/src/cdk-5.0-20200923.tgz\nln -s /nix/store/rz5l92zif4wkl1hli56jpwkz094df58k-lexilla510.tgz $PWD/src/lexilla510.tgz\nln -s /nix/store/9ysfqh8qshcxp3plj9i7rgaj5c79kv7j-libtermkey-0.22.tar.gz $PWD/src/libtermkey-0.22.tar.gz\nln -s /nix/store/b2ji7y5zn41nr8z9ikhlw791klbgnh56-lpeg-1.0.2.tar.gz $PWD/src/lpeg-1.0.2.tar.gz\nln -s /nix/store/gqzf2a90gkvh5bxmk7v6c4swh3xzr7bi-lua-5.4.4.tar.gz $PWD/src/lua-5.4.4.tar.gz\nln -s /nix/store/c1k2x3xnzkmsjhkf0ih8rbzbx3n97sln-scintilla524.tgz $PWD/src/scintilla524.tgz\nln -s /nix/store/di1wnz3rnrp60kqz5ykdazp323cr8bcq-v1_8_0.zip $PWD/src/v1_8_0.zip\ncd src\nmake deps\n"
```

To make this easier to read, I pasted that into an editor and converted each `\n` into a newline.
Here is the result.

```
ln -s /nix/store/nx8yz5xzq103ypjr2qb6nrjxnr9rf78m-444af9ca8a73151dbf759e6676d1035af469f01a.zip $PWD/src/444af9ca8a73151dbf759e6676d1035af469f01a.zip
ln -s /nix/store/rx0pp07k04vny2wfbd33xcaqa444yn6m-475d8d43f3418590c28bd2fb07ee9229d1fa2d07.zip $PWD/src/475d8d43f3418590c28bd2fb07ee9229d1fa2d07.zip
ln -s /nix/store/2f6qaarwrnbcnrnrjxzjmqysrczs4rka-9088723504b19f8611b66c119933a4dc7939d7b8.zip $PWD/src/9088723504b19f8611b66c119933a4dc7939d7b8.zip
ln -s /nix/store/980bp9jpcjiflslfazf7b0i90qvz4nx9-cdk-5.0-20200923.tgz $PWD/src/cdk-5.0-20200923.tgz
ln -s /nix/store/rz5l92zif4wkl1hli56jpwkz094df58k-lexilla510.tgz $PWD/src/lexilla510.tgz
ln -s /nix/store/9ysfqh8qshcxp3plj9i7rgaj5c79kv7j-libtermkey-0.22.tar.gz $PWD/src/libtermkey-0.22.tar.gz
ln -s /nix/store/b2ji7y5zn41nr8z9ikhlw791klbgnh56-lpeg-1.0.2.tar.gz $PWD/src/lpeg-1.0.2.tar.gz
ln -s /nix/store/gqzf2a90gkvh5bxmk7v6c4swh3xzr7bi-lua-5.4.4.tar.gz $PWD/src/lua-5.4.4.tar.gz
ln -s /nix/store/c1k2x3xnzkmsjhkf0ih8rbzbx3n97sln-scintilla524.tgz $PWD/src/scintilla524.tgz
ln -s /nix/store/di1wnz3rnrp60kqz5ykdazp323cr8bcq-v1_8_0.zip $PWD/src/v1_8_0.zip
cd src
make deps
```

So that scary-looking definition for `preConfigure` just creates a script that links to a bunch of tarfiles,
changes to the `src` directory, and runs `make deps`.
Actually, it does something else first, as we'll see shortly.

Now we know what the result of evaluating the expression is, but how does it work?
Let's take another look at the expression,
but this time I replaced part of it with a descriptive variable name
to make it easier to see the basic structure.

```
  preConfigure =
    aComplexExpression + ''
    cd src
    make deps
  '';
```

So `aComplexExpression` is evaluated,
and then two more lines, `cd src` and `make deps` are added to complete the script.
Let's investigate that complex expression.

```
lib.concatStringsSep "\n" (lib.mapAttrsToList (name: params:
      "ln -s ${fetchurl params} $PWD/src/${name}"
    ) (import ./deps.nix))
```

Here's the basic structure of that expression.

```
lib.concatStringsSep "\n" someStuff
```

You can probably guess that `someStuff` is an array of strings, which are concatenated with newlines to separate them.
Now we can zoom in on `someStuff`.

```
lib.mapAttrsToList (name: params:
      "ln -s ${fetchurl params} $PWD/src/${name}"
    ) (import ./deps.nix)
```

The function `mapAttrsToList` is defined in the
[nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/#chap-functions);
it calls a function for each attribute in a set and returns the result in a list.
The function that it's calling is given by the lambda expression below.


```
name: params: "ln -s ${fetchurl params} $PWD/src/${name}"
```

The set it operates on is obtained by importing `deps.nix`, which as we saw earlier
is a list of URLs and sha256 hashes.

Turning our attention back to the function, we see that it calls `fetchurl`,
which is also documented in the [nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/#fetchurl)
This function downloads a file from a URL, checks it against the hash, and returns the path to the downloaded file.

Let's run this step in the REPL.
To make things clearer, I've assigned names to the lambda, the data imported from `deps.nix`,
and the result of the function application.

```
nix-repl> fn = name: params: "ln -s ${fetchurl params} $PWD/src/${name}"

nix-repl> deps = import ./deps.nix

nix-repl> someStuff = lib.mapAttrsToList fn deps

nix-repl> someStuff
[ "ln -s /nix/store/nx8yz5xzq103ypjr2qb6nrjxnr9rf78m-444af9ca8a73151dbf759e6676d1035af469f01a.zip $PWD/src/444af9ca8a73151dbf759e6676d1035af469f01a.zip" "ln -s /nix/store/rx0pp07k04vny2wfbd33xcaqa444yn6m-475d8d43f3418590c28bd2fb07ee9229d1fa2d07.zip $PWD/src/475d8d43f3418590c28bd2fb07ee9229d1fa2d07.zip" "ln -s /nix/store/2f6qaarwrnbcnrnrjxzjmqysrczs4rka-9088723504b19f8611b66c119933a4dc7939d7b8.zip $PWD/src/9088723504b19f8611b66c119933a4dc7939d7b8.zip" "ln -s /nix/store/980bp9jpcjiflslfazf7b0i90qvz4nx9-cdk-5.0-20200923.tgz $PWD/src/cdk-5.0-20200923.tgz" "ln -s /nix/store/rz5l92zif4wkl1hli56jpwkz094df58k-lexilla510.tgz $PWD/src/lexilla510.tgz" "ln -s /nix/store/9ysfqh8qshcxp3plj9i7rgaj5c79kv7j-libtermkey-0.22.tar.gz $PWD/src/libtermkey-0.22.tar.gz" "ln -s /nix/store/b2ji7y5zn41nr8z9ikhlw791klbgnh56-lpeg-1.0.2.tar.gz $PWD/src/lpeg-1.0.2.tar.gz" "ln -s /nix/store/gqzf2a90gkvh5bxmk7v6c4swh3xzr7bi-lua-5.4.4.tar.gz $PWD/src/lua-5.4.4.tar.gz" "ln -s /nix/store/c1k2x3xnzkmsjhkf0ih8rbzbx3n97sln-scintilla524.tgz $PWD/src/scintilla524.tgz" "ln -s /nix/store/di1wnz3rnrp60kqz5ykdazp323cr8bcq-v1_8_0.zip $PWD/src/v1_8_0.zip" ]
```

So the result is the expected array of strings, each of which is the command to create a link to the downloaded file.
Evaluating this expression downloads the files (if they are not already in the nix store) as a (very important) side-effect.

The string concatenation step gives

```
nix-repl> aComplexExpression = lib.concatStringsSep "\n" someStuff

nix-repl> aComplexExpression
"ln -s /nix/store/nx8yz5xzq103ypjr2qb6nrjxnr9rf78m-444af9ca8a73151dbf759e6676d1035af469f01a.zip $PWD/src/444af9ca8a73151dbf759e6676d1035af469f01a.zip\nln -s /nix/store/rx0pp07k04vny2wfbd33xcaqa444yn6m-475d8d43f3418590c28bd2fb07ee9229d1fa2d07.zip $PWD/src/475d8d43f3418590c28bd2fb07ee9229d1fa2d07.zip\nln -s /nix/store/2f6qaarwrnbcnrnrjxzjmqysrczs4rka-9088723504b19f8611b66c119933a4dc7939d7b8.zip $PWD/src/9088723504b19f8611b66c119933a4dc7939d7b8.zip\nln -s /nix/store/980bp9jpcjiflslfazf7b0i90qvz4nx9-cdk-5.0-20200923.tgz $PWD/src/cdk-5.0-20200923.tgz\nln -s /nix/store/rz5l92zif4wkl1hli56jpwkz094df58k-lexilla510.tgz $PWD/src/lexilla510.tgz\nln -s /nix/store/9ysfqh8qshcxp3plj9i7rgaj5c79kv7j-libtermkey-0.22.tar.gz $PWD/src/libtermkey-0.22.tar.gz\nln -s /nix/store/b2ji7y5zn41nr8z9ikhlw791klbgnh56-lpeg-1.0.2.tar.gz $PWD/src/lpeg-1.0.2.tar.gz\nln -s /nix/store/gqzf2a90gkvh5bxmk7v6c4swh3xzr7bi-lua-5.4.4.tar.gz $PWD/src/lua-5.4.4.tar.gz\nln -s /nix/store/c1k2x3xnzkmsjhkf0ih8rbzbx3n97sln-scintilla524.tgz $PWD/src/scintilla524.tgz\nln -s /nix/store/di1wnz3rnrp60kqz5ykdazp323cr8bcq-v1_8_0.zip $PWD/src/v1_8_0.zip"
```

Finally, the last two lines `cd src` and `make deps` are added to complete the script.
