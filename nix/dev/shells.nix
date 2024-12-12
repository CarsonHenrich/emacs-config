# SPDX-FileCopyrightText: 2025 Carson Henrich <carson03henrich@gmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

/*
  This file holds reproducible shells with commands in them.

  They conveniently also generate config files in their startup hook.
*/
{ inputs
, cell
,
}:
let
  inherit (inputs.std) std;
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib // inputs.std.lib;
  pairToAttrs = name: value: value // { inherit name; };
in
builtins.mapAttrs (_: lib.dev.mkShell) {
  # Tool Homepage: https://numtide.github.io/devshell/
  default = {
    name = "default-devshell";

    imports = [
      std.devshellProfiles.default
    ];

    # Tool Homepage: https://nix-community.github.io/nixago/
    # This is Standard's devshell integration.
    # It runs the startup hook when entering the shell.
    nixago = [
      cell.configs.cog
      cell.configs.conform
      cell.configs.editorconfig
      cell.configs.githubsettings
      cell.configs.lefthook
      cell.configs.treefmt
      cell.configs.typos
    ];

    env = lib.mapAttrsToList pairToAttrs {
      nix_config.value = "extra-experimental-features = nix-command flakes";
    };

    packages = with nixpkgs; [
      nix-tree
    ];

    commands = lib.mapAttrsToList pairToAttrs {
      reuse = rec {
        category = "checks";
        package = nixpkgs.reuse;
        help = package.meta.description;
      };
      conform = rec {
        category = "checks";
        package = nixpkgs.conform;
        help = package.meta.description;
      };
      nil = rec {
        category = "checks";
        package = nixpkgs.nil;
        help = package.meta.description;
      };
    };
  };
}
