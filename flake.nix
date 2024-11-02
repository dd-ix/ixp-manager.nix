{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = (import nixpkgs) {
            inherit system;
          };
        in
        {
          packages = rec {
            ixp-manager = pkgs.callPackage ./derivation.nix { };
            default = ixp-manager;
          };
        }
      ) // {
      overlays.default = _: prev: {
        inherit (self.packages."${prev.system}") ixp-manager;
      };

      nixosModules = rec {
        ixp-manager = ./module.nix;
        default = ixp-manager;
      };
    };
}
