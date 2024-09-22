{
  description = "Packages VESC Tool into a flake.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    src = {
      url = "github:vedderb/vesc_tool/release_6_05";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, src }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
    in {
      packages = with pkgs; {
        inherit vesc-tool;
        default = vesc-tool;
      };
    }
  ) // {
    overlays.default = import ./overlay.nix { inherit src; };
  };
}
