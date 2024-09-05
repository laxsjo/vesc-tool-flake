# vesc-tool-flake
A Nix flake that wraps around VESC Tool, which easily allows you to override the
[VESC Tool source](https://github.com/vedderb/vesc_tool/) git commit used when building the package.

## Usage

This flake's only outputs are `packages.<system>.default`, for each system
created by flake-utils's `eachDefaultSystem`. Include these in
`environment.systemPackages` or any other list that accepts packages to install
it to your system (like `home-manager.users.<user>.home.packages` for instance). 

You can try it directly from your shell by running the following command:
```shell
nix run github:laxsjo/vesc-tool-flake
```

Here is a sample flake.nix NixOS configuration that install VESC Tool as a
system package.

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
          environment.systemPackages = [
              vesc-tool-flake.packages.${system}.default
          ];
        }
      ];
    };
  };
}
```

If you want to build a different version of VESC Tool, you only need to override
this flake's `vesc-tool-src` input.

To set it to a specific branch:
```nix
{  
  vesc-tool-flake = {
    url = "github:laxsjo/vesc-tool-flake";
    inputs.vesc-tool-src.url = "github:vedderb/vesc_tool/master";
  };
}
```

To set it to a specific commit:
```nix
{  
  vesc-tool-flake = {
    url = "github:laxsjo/vesc-tool-flake";
    inputs.vesc-tool-src.url = "github:vedderb/vesc_tool/4b3cb2a0555576e762491678c08d5d2286f9d6f9";
  };
}
```
