{
  description = "Carson Henrich's emacs configuration";

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
      imports = [ inputs.flake-parts.flakeModules.easyOverlay ];
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
          final,
          ...
        }:
        let
        pkgs' = import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.emacs-overlay.overlays.emacs
            inputs.org-babel.overlays.default
          ];
        };
        in
        {
          _module.args = {
            pkgs = pkgs';
          };

          overlayAttrs = {
            inherit (config.packages) emacs emacs-early-init emacs-env;
          };

          packages =
            let
              inherit (inputs.nixpkgs) lib;
              org = inputs.org-babel.lib;

              packageOverrides = _: prev: {
                elispPackages = prev.elispPackages.overrideScope (
                  final.callPackage ./package-overrides.nix { inherit (prev) emacs; }
                );
              };

              initEl = pkgs'.tangleOrgBabelFile "init.el" ./README.org {
                processLines = org.excludeHeadlines (org.tag "early");
              };
            in
            rec {
              emacs = pkgs.emacs-pgtk;

              emacs-early-init = pkgs.tangleOrgBabelFile "early-init.el" ./README.org {
                processLines = org.selectHeadlines (org.tag "early");
              };

              emacs-env =
                (inputs.twist.lib.makeEnv {
                  pkgs = pkgs;
                  # NOTE Needed for hot reloading
                  # TODO Find out if I want to do hot reloading
                  exportManifest = true;

                  emacsPackage = emacs;
                  lockDir = ./.lock;
                  initFiles = [ initEl ];
                  inputOverrides = import ./input-overrides.nix { inherit lib; };
                  registries = import ./registries.nix {
                    inherit inputs;
                    emacsSrc = emacs.src;
                  };
                }).overrideScope
                  packageOverrides;
            };

          devShells = import ./shell.nix { inherit pkgs; };
          apps = config.packages.emacs-env.makeApps { lockDirName = ".lock"; };
        };
    };
}
