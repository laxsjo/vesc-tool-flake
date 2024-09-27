{
  description = "Packages VESC Tool into a flake.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    src = {
      url = "github:vedderb/vesc_tool/release_6_05";
      flake = false;
    };
    bldcSrc = {
      url = "github:vedderb/bldc/release_6_05";
      flake = false;
    };
  };

  # TODO: Add support for building on/for other systems.
  outputs = { self, nixpkgs, flake-utils, src, bldcSrc }@inputs: flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
    in {
      packages = with pkgs; {
        inherit
          vesc-tool
          vesc-tool-free
          vesc-tool-copper
          vesc-tool-bronze
          vesc-tool-silver
          vesc-tool-gold
          vesc-tool-platinum;
        bldc-fw = pkgs.callPackage ./pkgs/vesc-tool/bldc-fw.nix { src = bldcSrc; };
        default = vesc-tool;
      };
    }
  ) // {
    overlays.default = (nixpkgs.lib.makeOverridable (import ./overlay.nix)) { inherit src bldcSrc; };
    # For development in the nix repl
    inherit self;
  };
}
