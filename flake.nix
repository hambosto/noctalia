{
  description = "All in one configuration for noctalia ecosystem";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      flake = false;
    };

    umbriel = {
      url = "github:noctalia-dev/umbriel";
      flake = false;
    };

    xdg-desktop-portal-umbriel = {
      url = "github:noctalia-dev/xdg-desktop-portal-umbriel";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem =
        perSystem:
        lib.genAttrs systems (
          system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          perSystem { inherit pkgs system; }
        );
    in
    {
      overlays.default = final: prev: {
        noctalia = final.callPackage ./packages/noctalia.nix { src = inputs.noctalia; };

        umbriel = final.callPackage ./packages/umbriel.nix { src = inputs.umbriel; };

        xdg-desktop-portal-umbriel = final.callPackage ./packages/xdg-desktop-portal-umbriel.nix {
          src = inputs.xdg-desktop-portal-umbriel;
        };
      };

      packages = forEachSystem (
        { pkgs, ... }:
        {
          noctalia = pkgs.callPackage ./packages/noctalia.nix { src = inputs.noctalia; };

          umbriel = pkgs.callPackage ./packages/umbriel.nix { src = inputs.umbriel; };

          xdg-desktop-portal-umbriel = pkgs.callPackage ./packages/xdg-desktop-portal-umbriel.nix {
            src = inputs.xdg-desktop-portal-umbriel;
          };
        }
      );

      homeManagerModules.noctalia = { lib, pkgs, ... }: {
        imports = [ ./modules/noctalia/home-module.nix ];
        programs.noctalia.package = lib.mkDefault self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia;
      };

      homeManagerModules.umbriel = { lib, pkgs, ... }: {
        imports = [ ./modules/umbriel/home-module.nix ];
        programs.umbriel.package = lib.mkDefault self.packages.${pkgs.stdenv.hostPlatform.system}.umbriel;
      };

      nixosModules.noctalia = { lib, pkgs, ... }: {
        imports = [ ./modules/noctalia/nixos-module.nix ];
        programs.noctalia.package = lib.mkDefault self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia;
      };

      nixosModules.umbriel = { lib, pkgs, ... }: {
        imports = [ ./modules/umbriel/nixos-module.nix ];
        programs.umbriel.package = lib.mkDefault self.packages.${pkgs.stdenv.hostPlatform.system}.umbriel;
        programs.umbriel.portalPackage =
          lib.mkDefault
            self.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-umbriel;
      };
    };
}
