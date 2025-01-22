# SPDX-FileCopyrightText: 2025 Carson Henrich <carson03henrich@gmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
# TODO Credit to cmacrae


{ inputs, cell }:
let
  inherit (inputs) self;
  inherit (inputs) nixpkgs;
  emacs = pkgs.emacs-pgtk;
  Readme = (inputs.std.incl (inputs.self) [ "README.org" ]) + /README.org;
  lockDir = inputs.std.incl (inputs.self + /.lock) [ "flake.nix" "flake.lock" "archive.lock" ];

  pkgs = nixpkgs.appendOverlays [
    inputs.emacs-overlay.overlays.default
    inputs.org-babel.overlays.default
  ];

  l = pkgs.lib // builtins;

  org = inputs.org-babel.lib;

  initEl = pkgs.tangleOrgBabelFile "init.el" Readme {
    processLines = (lines: org.excludeHeadlines (org.tag "early") (org.excludeHeadlines (org.tag "ARCHIVE") lines));
  };

  earlyInitEl = pkgs.tangleOrgBabelFile "early-init.el" Readme {
    processLines = (lines: org.selectHeadlines (org.tag "early") (org.excludeHeadlines (org.tag "ARCHIVE") lines));
  };

  treeSitterLoadPath = l.pipe pkgs.tree-sitter-grammars [
    (l.filterAttrs (name: _: name != "recurseForDerivations"))
    l.attrValues
    (map (drv: {
      # Some grammars don't contain "tree-sitter-" as the prefix,
      # so add it explicitly.
      name = "libtree-sitter-${
        l.pipe (l.getName drv) [
          (l.removeSuffix "-grammar")
          (l.removePrefix "tree-sitter-")
        ]
      }${pkgs.stdenv.targetPlatform.extensions.sharedLibrary}";
      path = "${drv}/parser";
    }))
    (pkgs.linkFarm "treesit-grammars")
  ];
in
{
  inherit emacs initEl earlyInitEl Readme;

  emacs-env = (inputs.twist.lib.makeEnv {
    inherit pkgs;
    inherit lockDir;
    emacsPackage = emacs;

    inputOverrides = import ./input-overrides.nix;
    registries = import ./registries.nix { inherit inputs; emacsSrc = emacs.src; };
    initFiles = [ initEl ];
    exportManifest = true;
    configurationRevision =
      with builtins;
      "${substring 0 8 self.lastModifiedDate}.${
        if self ? rev then
          substring 0 7 self.rev
        else
          "dirty.${substring 0 7 (hashFile "sha256" Readme)}"
      }";

    extraSiteStartElisp = ''
      (add-to-list 'treesit-extra-load-path "${treeSitterLoadPath}/")
    '';
  }).overrideScope
    (
      _final: prev: {
        elispPackages = prev.elispPackages.overrideScope (
          pkgs.callPackage ./package-overrides.nix { inherit emacs; }
        );
      }
    );
}
