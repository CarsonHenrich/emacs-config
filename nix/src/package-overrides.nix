# SPDX-FileCopyrightText: 2025 Carson Henrich <carson03henrich@gmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
{ cmake
, emacs
, git
, gcc
, python3
, nodejs_23
, libvterm-neovim
}:
_final: prev: {
  forge = prev.forge.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ git ];
  });

  treemacs = prev.treemacs.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [
      git
      python3
    ];
  });

  mathjax = prev.mathjax.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ nodejs_23 ];
  });

  vterm = prev.vterm.overrideAttrs (o: {
    nativeBuildInputs = [
      cmake
      gcc
    ];
    buildInputs = o.buildInputs ++ [ libvterm-neovim ];
    cmakeFlags = [ "-DEMACS_SOURCE=${emacs.src}" ];
    preBuild = ''
      mkdir -p build
      cd build
      cmake ..
      make
      install -m444 -t . ../*.so
      install -m600 -t . ../*.el
      cp -r -t . ../etc
      rm -rf {CMake*,build,*.c,*.h,Makefile,*.cmake}
    '';
  });
}
