# vesc-tool-flake
A Nix flake that wraps around VESC Tool, which easily allows you to override the [VESC Tool source](https://github.com/vedderb/vesc_tool/) git commit used when building the package.

There is one package per paid tier of VESC Tool. They are as follows (with their respective package names):

- VESC Tool Original: `vesc-tool`
- VESC Tool Free: `vesc-tool-free`
- VESC Tool Copper: `vesc-tool-copper`
- VESC Tool Bronze: `vesc-tool-bronze`
- VESC Tool Silver: `vesc-tool-silver`
- VESC Tool Gold: `vesc-tool-gold`
- VESC Tool Platinum: `vesc-tool-platinum`

The tier only changes the logo inside of VESC Tool and the desktop icon.

You can unfortunately only have a single version of VESC Tool installed at a time, due to the desktop entry files otherwise colliding.

## Usage
This flake outputs packages under `packages.<system>.*` for each system created by flake-utils's `eachDefaultSystem` (I have only tested x86_64-linux, sorry). Include these in `environment.systemPackages` or any other list that accepts packages (like `home-manager.users.<user>.home.packages` for instance) to install them. 

There is also an overlay under the output `overlays.default` which includes all of the packages into `pkgs`. 

After you've installed it, you can either run it with the desktop item installed by the package, or by running `vesc_tool` in your terminal. The binary executables (i.e. what you type in the terminal to run the program) for all of VESC Tool's tiers are named `vesc_tool_<tier>` except for VESC Tool Original, which is just named `vesc_tool`

You can try it directly from your shell by running the following command:
```shell
nix run github:laxsjo/vesc-tool-flake
```

Here is a sample `flake.nix` NixOS configuration that installs VESC Tool as a
system package using the overlay.

```nix
{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    vesc-tool-flake = {
      url = "github:laxsjo/vesc-tool-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, vesc-tool-flake, ... }: {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs.overlays = [
            vesc-tool-flake.overlays.default
          ];
        }
        ({ pkgs }: {
          environment.systemPackages = [
            pkgs.vesc-tool
          ];
        })
      ];
    };
  };
}
```

If you prefer, you can also include the package directly (assuming that you have a `system` variable defined in your scope):

```nix
{
  environment.systemPackages = [
    vesc-tool-flake.packages.${system}.default
  ];
}
```

By default release 6.05 of VESC Tool is built. If you want to build a different version you can override this flake's `src` input. There is also the input `bldcSrc`, which is used when building the included standard firmwares for bldc VESCs. See `fwBoards` under **Overridable Arguments**. Formally, the bldc version used should "be the same version" as VESC Tool (i.e. the `release_6_05` branch in both repos), but in theory any version of bldc could be used.

You can either use a branch/tag:
```nix
{  
  vesc-tool-src = {
    url = "github:vedderb/vesc_tool/master";
  };
  vesc-tool-flake = {
    url = "github:laxsjo/vesc-tool-flake";
    inputs.src.follows = "vesc-tool-src";
  };
}
```

Or you can use a specific commit:
```nix
{
  vesc-tool-src = {
    url = "github:vedderb/vesc_tool/4b3cb2a0555576e762491678c08d5d2286f9d6f9";
  };
  vesc-tool-flake = {
    url = "github:laxsjo/vesc-tool-flake";
    inputs.src.url = "vesc-tool-src";
  };
}
```

You can then easily update VESC Tool by running `nix flake update vesc-tool-src` in your flake.

> **NOTE:** You need to at least have nix version 2.19 installed to be able to run `nix flake update <input>`! Currently only nix 2.18 is installed with nixpkgs by default, so you need to install a newer version of nix if you want to run it. The package nixVersion.nix_2_19 does exactly that, try it using `nix-shell -p nixVersions.nix_2_19`.

### Included Firmwares
This flake builds VESC Tool with all standard included firmwares and bootloaders for BMS and ESP VESCs and a generic bootloader for bldc VESCs. These show up in the "Firmware" page under "Included Files" in VESC Tool.. By default, no other firmware for any bldc target boards is included. This can be changed by overriding the `fwBoards` argument (see **Overridable Arguments**). Setting it to `"all"` builds all standard targets, outputing an identical build to the ones at [vesc-project.com](https://vesc-project.com) (unless I made any mistakes in this flake...). Note that this dramatically increases the build time. You can also set it to a list of target boards to only build the board versions which you need.

### Overridable Arguments
There are a number of arguments that are overridable in the provided packages to customize the build process. They are as follows:
- `src`: The source tree containing VESC Tool's source code. Alternative mechanism to overriding the flake's `src` input.
- `bldcSrc`: The source tree containing bldc's source code used when building then standard included bldc firmwares. Alternative mechanism to overriding the flake's `bldcSrc` input. 
- `kind`: The VESC Tool tier type to build, one of `"original"`, `"free"`, `"bronze"`, `"silver"`, `"gold"`, or `"platinum"`.
- `fwBoards`: The target BLDC boards for which standard firmware should be built and included. Either `"all"` to build all firmwares, or a list of list of bldc board names, i.e. a list of bldc "fw_*" Makefile targets without the "fw_" prefix.

These could, for instance, be overriden like this:
```nix
{  
  environment.systemPackages = [
    (pkgs.vesc-tool.override {
      src = pkgs.fetchFromGitHub {
        owner = "vedderb";
        repo = "vesc_tool";
        rev = "1c1a5ea0faa5f3e1d1eb9b63d0048d0cdc68e258";
        sha256 = "sha256-1BaXXxv1bsRa8oHVxBeSGt7Nj9F3Hjz+wh0qIMX7HD8=";
      };
      bldcSrc = pkgs.fetchFromGitHub {
        owner = "vedderb";
        repo = "bldc";
        rev = "b6e53d3f28e9fd7a54b266c149abbf8a1c23f80a";
        sha256 = "sha256-4Q0sAEglXONL6InlVfwVKtQ2ZXKGhfrVLBevnWyjXZ0=";
      };
      kind = "platinum";
      fwBoards = [ "fw_100_250" "fw_basic" "fw_ubox_100" ];
    })
  ];
}
```

You can also override these for the entire overlay. All arguments except `kind` are present (since the overlay already includes all kinds!). For instance:

```nix
vesc-tool-flake.overlays.default.override { fwBoards = "all"; }
```