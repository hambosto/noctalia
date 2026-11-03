{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.noctalia;
in
{
  disabledModules = [ "programs/wayland/noctalia.nix" ];

  options.programs.noctalia = {
    enable = lib.mkEnableOption "Whether to enable noctalia, a lightweight Wayland shell and bar.";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "The noctalia package to install.";
    };

    systemd = {
      enable = lib.mkEnableOption "Enables a systemd user service for noctalia.";
      target = lib.mkOption {
        type = lib.types.str;
        default = "graphical-session.target";
        example = "hyprland-session.target";
        description = "The systemd user target for the noctalia service.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.systemd.enable || cfg.package != null;
        message = "programs.noctalia.package cannot be null when programs.noctalia.systemd.enable is true";
      }
    ];

    environment.systemPackages = lib.optional (cfg.package != null) cfg.package;

    systemd.user.services.noctalia = lib.mkIf cfg.systemd.enable {
      description = "Noctalia - A lightweight Wayland shell and bar";
      documentation = [ "https://docs.noctalia.dev/noctalia/" ];
      partOf = [ cfg.systemd.target ];
      after = [ cfg.systemd.target ];
      wantedBy = [ cfg.systemd.target ];
      restartTriggers = [ cfg.package ];
      environment.PATH = lib.mkForce null;
      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
      };
    };
  };
}
