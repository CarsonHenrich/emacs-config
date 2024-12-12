{
  description = "cmacrae's systems configuration";

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

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    # Emacs
    twist.url = "github:emacs-twist/twist.nix";
    org-babel.url = "github:emacs-twist/org-babel";
    emacs.url = "github:emacs-mirror/emacs";
    emacs.flake = false;
    melpa.url = "github:melpa/melpa";
    melpa.flake = false;
    gnu-elpa.url = "github:elpa-mirrors/elpa";
    gnu-elpa.flake = false;
    nongnu-elpa.url = "github:elpa-mirrors/nongnu";
    nongnu-elpa.flake = false;
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-darwin"
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        {
          config,
          pkgs,
          system,
          emacs-env,
          emacs-early-init,
          ...
        }:
        {
          _module.args = {
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                inputs.emacs-overlay.overlays.emacs
                inputs.org-babel.overlays.default
              ];
            };

            emacs-env = import ./emacs.nix { inherit inputs pkgs; };

            emacs-early-init =
              let
                org = inputs.org-babel.lib;
              in
              (pkgs.tangleOrgBabelFile "early-init.el" ./README.org {
                processLines = org.selectHeadlines (org.tag "early");
              });

            config.extraSpecialArgs = {
              inherit emacs-env emacs-early-init;
            };
          };

          packages = {
            inherit emacs-env emacs-early-init;
          };

          apps = emacs-env.makeApps { lockDirName = ".lock"; };
        };
    };
}
