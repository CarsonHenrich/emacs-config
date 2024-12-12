# SPDX-FileCopyrightText: 2025 Carson Henrich <carson03henrich@gmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

{
  description = "My Emacs Configuration, Built with Nix";

  inputs = {
    # Nixpkgs
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs.follows = "nixpkgs-unstable";

    # Flake Utilities
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixago = {
      url = "github:nix-community/nixago";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    std = {
      url = "github:divnix/std";
      inputs = {
        devshell.follows = "devshell";
        nixago.follows = "nixago";
        nixpkgs.follows = "nixpkgs";
      };
    };
    dev-configs = {
      url = "github:ghenricc/dev-configs";
      inputs = {
        std.follows = "std";
        devshell.follows = "devshell";
        nixago.follows = "nixago";
        nixpkgs.follows = "nixpkgs";
      };
    };

    # Emacs
    twist.url = "github:emacs-twist/twist.nix";
    org-babel.url = "github:emacs-twist/org-babel";
    emacs = {
      url = "github:emacs-mirror/emacs";
      flake = false;
    };
    melpa = {
      url = "github:melpa/melpa";
      flake = false;
    };
    gnu-elpa = {
      url = "github:elpa-mirrors/elpa";
      flake = false;
    };
    nongnu-elpa = {
      url = "github:elpa-mirrors/nongnu";
      flake = false;
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://carsonhenrich.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "carsonhenrich.cachix.org-1:hahYg63yinXhJVLCZd49InX9Ewng2u0yS+gjgATkG5Q="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    inputs @ { self
    , std
    , ...
    }:
    std.growOn
      {
        inherit inputs;
        cellsFrom = std.incl ./nix [
          "src"
          "dev"
        ];
        cellBlocks = with std.blockTypes; [
          # Things for downstream usage
          (installables "installables")
          (runnables "runnables")
          # Repo: Dev Environment
          (nixago "configs")
          (devshells "shells" { ci.build = true; })
        ];
      }
      {
        packages = std.harvest self [ "src" "installables" ];
        apps = std.harvest self [ "src" "runnables" ];
        devShells = std.harvest self [ "dev" "shells" ];
      };
}
