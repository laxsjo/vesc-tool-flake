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
      pkgs = nixpkgs.legacyPackages.${system};
      name = "vesc_tool";
      desktopItem = pkgs.makeDesktopItem {
        name = "com.vesc-project.";
        exec = "vesc_tool";
        icon = "vesc_tool.svg";
        comment = "IDE for controlling and configuring VESC-compatible motor controllers and other devices.";
        desktopName = "VESC Tool";
        genericName = "Integrated Development Environment";
        categories = [ "Development" ];
      };
      vesc-tool = pkgs.stdenv.mkDerivation {
        pname = name;
        version = src.rev or "unknown";
        
        meta = with pkgs.lib; {
          description = "VESC Tool";
          platforms = platforms.linux;
        };
        
        src = src;

        configurePhase = ''
          qmake -config release "CONFIG += release_lin build_free exclude_fw"
        '';
        buildPhase = ''
          make -j8
        '';
        installPhase = ''
          mkdir -p $out/bin
          mkdir -p $out/share/icons/hicolor/scaled/apps
          mkdir -p $out/share/applications
          
          cp build/lin/vesc_tool_* $out/bin/vesc_tool
          cp res/version/neutral_v.svg $out/share/icons/hicolor/scaled/apps/vesc_tool.svg
          cp ${desktopItem}/share/applications/* $out/share/applications/
        '';
        
        buildInputs = [ pkgs.libsForQt5.qtbase ];
        
        nativeBuildInputs = [
          pkgs.cmake
          pkgs.libsForQt5.qtbase
          pkgs.libsForQt5.qtquickcontrols2
          pkgs.libsForQt5.qtgamepad
          pkgs.libsForQt5.qtconnectivity
          pkgs.libsForQt5.qtpositioning
          pkgs.libsForQt5.qtserialport
          pkgs.libsForQt5.qtgraphicaleffects
          pkgs.libsForQt5.wrapQtAppsHook
          
          # Make the desktop icon work
          pkgs.copyDesktopItems
        ];
      };
    in {
      packages.vesc-tool = vesc-tool;
      packages.default = vesc-tool;
    }
  );
}
