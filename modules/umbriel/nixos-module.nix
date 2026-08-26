{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.umbriel;
in
{
  disabledModules = [ "programs/wayland/umbriel.nix" ];

  options.programs.umbriel = {
    enable = lib.mkEnableOption "Umbriel, a Wayland compositor built on wlroots and SceneFX.";

    package = lib.mkPackageOption pkgs "umbriel" {
      nullable = true;
      extraDescription = "Set to `null` to not add any umbriel package to your path.";
    };

    portalPackage = lib.mkPackageOption pkgs "xdg-desktop-portal-umbriel" {
      nullable = true;
      extraDescription = "Set to `null` to not add any xdg-desktop-portal-umbriel package to your path.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = cfg.package != null;
            message = "programs.umbriel.package cannot be null when programs.umbriel.enable is true";
          }
        ];
      }

      (lib.mkIf (cfg.package != null) {
        environment.systemPackages = [ cfg.package ];
        services.displayManager.sessionPackages = [ cfg.package ];
      })

      (lib.mkIf (cfg.portalPackage != null) {
        xdg.portal = {
          enable = lib.mkDefault true;
          extraPortals = [ cfg.portalPackage ];
          configPackages = [ cfg.portalPackage ];
        };
      })
    ]
  );
}
