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

# Prerequisites

To follow along with this tutorial, you will need access to a computer or (virtual machine) with Nix installed
and *flakes enabled*.

I recommend the installer and quick start guide from [zero-to-nix.com](https://zero-to-nix.com/start/install).
This installer automatically enables flakes.

More documentation (and another installer) available at [nixos.org](https://nixos.org/).

To enable flakes on an existing installation, see the instructions in the [NixOS wiki](https://nixos.wiki/wiki/Flakes).
