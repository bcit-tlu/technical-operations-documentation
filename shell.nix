{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = [
    pkgs.python315
  ];
  shellHook = ''
    python -m venv .venv
    source .venv/bin/activate
    pip install zensical
  '';
}
