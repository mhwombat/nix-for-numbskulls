---
title: 'A Beginner-friendly Flake Tutorial'
subtitle: '\emph{\today}'
author: 'Amy de Buitléir'
mainfont: DejaVu Sans
monofont: Noto Sans Mono
fontsize: 10
margin-top: 2cm
margin-bottom: 2cm
margin-left: 2cm
margin-right: 2cm
toc: true
toc-depth: 2
number-sections: true
listings: true
colorlinks: true
hyperrefoptions:
- linktoc=all
- hyperfootnotes=true
- colorlinks=true
include-in-header:
- header-extras.tex
...

# Introduction



## Why Nix?

If you've opened this PDF, you already have your own motivation for learning Nix.
Here's how it helps me.
As a researcher, I tend to work on a series of short-term projects, mostly demos and prototypes.
For each one, I typically develop some software using a compiler,
often with some open source libraries.
Often I use other tools to analyse data or generate documentation, for example.

Problems would arise when handing off the project to colleagues;
they would report errors when trying to build or run the project.
Belatedly I would realise that my code relies on a library that they need to install.
Or perhaps they had installed the library, but the version they're using is incompatible.

Using containers helped with the problem.
However, I didn't want to _develop_ in a container.
I did all my development in my nice, familiar, environment with my custom aliases and shell prompt.
and _then_ I containerised the software.
This added step was annoying for me,
and if my colleague wanted to do some additional development,
they would probably extract all of the source code from the container first anyway.
Containers are great, but this isn't the ideal use case for them.

Nix allows me to work in my custom environment, but forces me to specify any dependencies.
It automatically tracks the version of each dependency so that it can replicate the environment wherever and whenever it's needed.

## Why _flakes_?

Flakes are labeled as an experimental feature, so it might seem safer to avoid them.
However, they have been in use for years, and there is widespread adoption,
so the aren't going away any time soon.
Flakes are easier to understand, and offer more features than the traditional Nix approach.
After weighing the pros and cons, I feel it's better to learn and use flakes;
and this seems to be the general consensus.

## Prerequisites

To follow along with this tutorial, you will need access to a computer or (virtual machine) with Nix installed
and *flakes enabled*.

I recommend the installer from [zero-to-nix.com](https://zero-to-nix.com/start/install).
This installer automatically enables flakes.

More documentation (and another installer) available at [nixos.org](https://nixos.org/).

To enable flakes on an existing installation, see the instructions in the [NixOS wiki](https://nixos.wiki/wiki/Flakes).

## Tip: Pay attention to those hyphens

There are hyphenated and unhyphenated versions of many Nix commands.
For example, `nix-shell` and `nix shell` are two different commands.

Generally speaking, the unhyphenated versions are for working directly with flakes,
while the hyphenated versions are for everything else.

