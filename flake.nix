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
    {
      self,
      flake-utils,
      nixpkgs,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        fmtDate =
          raw:
          let
            year = builtins.substring 0 4 raw;
            month = builtins.substring 4 2 raw;
            day = builtins.substring 6 2 raw;
          in
          "${year}-${month}-${day}";
        date = fmtDate self.lastModifiedDate;
        version = "unstable-${date}-${self.shortRev or "dirty"}";
      in
      {
        packages = {
          noctalia = pkgs.callPackage ./packages/noctalia.nix {
            src = inputs.noctalia;
            inherit version;
          };

          umbriel = pkgs.callPackage ./packages/umbriel.nix {
            src = inputs.umbriel;
            inherit version;
          };

          xdg-desktop-portal-umbriel = pkgs.callPackage ./packages/xdg-desktop-portal-umbriel.nix {
            src = inputs.xdg-desktop-portal-umbriel;
            inherit version;
          };
        };
      }
    )
    // {
      overlays.default = _: prev: {
        inherit (self.packages.${prev.stdenv.system})
          noctalia
          umbriel
          xdg-desktop-portal-umbriel
          ;
      };

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
