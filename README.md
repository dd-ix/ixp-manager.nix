# ixp-manager.nix

Nix Module for [IXP-Manager](https://www.ixpmanager.org/).

## Usage

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    ixp-manager = {
      url = "github:dd-ix/ixp-manager.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, ixp-manager, ... }: {
    nixosConfigurations = {
      hostname = nixpkgs.lib.nixosSystem {
        modules = [
          ixp-manager.nixosModules.default
          { nixpkgs.overlays = [ ixp-manager.overlays.default ]; }
        ];
      };
    };
  };
}
```
