{ src }:

final: prev: rec {
  vesc-tool = prev.callPackage ./pkgs/vesc-tool { inherit src; };
}