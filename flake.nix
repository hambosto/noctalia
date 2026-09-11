{
  description = "All in one configuration for noctalia ecosystem";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
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
      flake-utils,
      nixpkgs,
      ...
    }:
    let
      pkgsFor = pkgs: self.packages.${pkgs.stdenv.hostPlatform.system};
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          noctalia = pkgs.callPackage ./packages/noctalia.nix {
            src = inputs.noctalia;
            stdenv = pkgs.gcc16Stdenv;
          };

          umbriel = pkgs.callPackage ./packages/umbriel.nix {
            src = inputs.umbriel;
            stdenv = pkgs.gcc16Stdenv;
          };

          xdg-desktop-portal-umbriel = pkgs.callPackage ./packages/xdg-desktop-portal-umbriel.nix {
            src = inputs.xdg-desktop-portal-umbriel;
            stdenv = pkgs.gcc16Stdenv;
          };
        };
      }
    )
    // {
      overlays.default = final: prev: {
        inherit (pkgsFor prev) noctalia umbriel xdg-desktop-portal-umbriel;
      };

      homeManagerModules.noctalia = { lib, pkgs, ... }: {
        imports = [ ./modules/noctalia/home-module.nix ];
        programs.noctalia.package = lib.mkDefault (pkgsFor pkgs).noctalia;
      };

      homeManagerModules.umbriel = { lib, pkgs, ... }: {
        imports = [ ./modules/umbriel/home-module.nix ];
        programs.umbriel.package = lib.mkDefault (pkgsFor pkgs).umbriel;
      };

      nixosModules.noctalia = { lib, pkgs, ... }: {
        imports = [ ./modules/noctalia/nixos-module.nix ];
        programs.noctalia.package = lib.mkDefault (pkgsFor pkgs).noctalia;
      };

      nixosModules.umbriel = { lib, pkgs, ... }: {
        imports = [ ./modules/umbriel/nixos-module.nix ];
        programs.umbriel.package = lib.mkDefault (pkgsFor pkgs).umbriel;
        programs.umbriel.portalPackage = lib.mkDefault (pkgsFor pkgs).xdg-desktop-portal-umbriel;
      };
    };
}
