{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;
{
  default = mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";
    packages = with pkgs; [
      nix
      git
      cachix
      just
    ];
  };
}
