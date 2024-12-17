{ nixpkgs ? import <nixpkgs> {  } }:

let
  pkgs = with nixpkgs.python312Packages; [
    jinja2
    pyyaml
  ];

in
  nixpkgs.stdenv.mkDerivation {
    name = "env";
    buildInputs = pkgs;
  }
