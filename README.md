# Noctalia Flake

[![Update Packages](https://github.com/hambosto/noctalia/actions/workflows/update-packages.yml/badge.svg)](https://github.com/hambosto/noctalia/actions/workflows/update-packages.yml)

All-in-one Nix configuration for the [Noctalia](https://github.com/noctalia-dev) ecosystem.

This flake provides up-to-date packages and ready-to-use NixOS / Home Manager modules for:

| Package | Description | Source |
|---|---|---|
| `noctalia` | A sleek, customizable desktop shell crafted for Wayland | [noctalia-dev/noctalia](https://github.com/noctalia-dev/noctalia) |
| `umbriel` | A Wayland compositor built on wlroots and SceneFX | [noctalia-dev/umbriel](https://github.com/noctalia-dev/umbriel) |
| `xdg-desktop-portal-umbriel` | XDG desktop portal backend for the Umbriel compositor | [noctalia-dev/xdg-desktop-portal-umbriel](https://github.com/noctalia-dev/xdg-desktop-portal-umbriel) |

Packages are built from the latest upstream sources (`unstable-<date>-<rev>`), tracked by a lockfile that is refreshed automatically every hour. Supported platforms: `x86_64-linux` and `aarch64-linux`.

## Flake Outputs

```
├── overlays.default                  # Adds all three packages to an existing pkgs
├── packages.<system>.{               # Buildable/runnable packages
│     noctalia,
│     umbriel,
│     xdg-desktop-portal-umbriel }
├── homeManagerModules.{noctalia, umbriel}
└── nixosModules.{noctalia, umbriel}
```

## Quick Start

### Run without installing

```bash
nix run github:hambosto/noctalia#noctalia
nix run github:hambosto/noctalia#umbriel
```

### Use as an input

```nix
# flake.nix
{
  inputs.noctalia.url = "github:hambosto/noctalia";
}
```

### Overlay

```nix
nixpkgs.overlays = [
  inputs.noctalia.overlays.default
];
```

## Home Manager

### Noctalia (shell & bar)

```nix
{
  imports = [ inputs.noctalia.homeManagerModules.noctalia ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings = {
      shell.font = "JetBrainsMono Nerd Font";

      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
    };

    customPalettes."my-palette" = {
      name = "My Palette";
      colors = { /* see palette docs below */ };
    };
  };
}
```

Options:

| Option | Type | Default | Description |
|---|---|---|---|
| `enable` | bool | `false` | Enable Noctalia, a lightweight Wayland shell and bar |
| `package` | package | flake package | The Noctalia package to install |
| `systemd.enable` | bool | `false` | Run Noctalia as a systemd user service |
| `checkConfig` | bool | `true` | Validate `settings` at build time (`noctalia config validate`) |
| `settings` | attrset \| str \| path | `{ }` | Settings written to `~/.config/noctalia/config.toml`. Accepts a Nix attrset (converted to TOML), a raw TOML string, or a path to a `.toml` file. See the [configuration docs](https://docs.noctalia.dev/noctalia/configuration/). Can still be overridden at runtime via the settings menu |
| `customPalettes.<name>` | attrset \| str \| path | `{ }` | Custom color palettes written to `~/.config/noctalia/palettes/<name>.json`. See the [palette docs](https://docs.noctalia.dev/noctalia/theming/palette/#custom-palette-files) |

When `systemd.enable` is set, the service binds to `wayland.systemd.target` (`graphical-session.target` by default) and restarts automatically whenever the config or palettes change.

> Note: the module disables nixpkgs' built-in `programs/noctalia.nix` to avoid conflicts.

### Umbriel (compositor)

```nix
{
  imports = [ inputs.noctalia.homeManagerModules.umbriel ];

  programs.umbriel = {
    enable = true;

    settings = {
      general.autostart = [ "noctalia" ];
      layout.gap = 5;
      input.keyboard.layout = "de";

      keybinds = {
        "Mod+Return" = "spawn:kitty";
        "Mod+Q" = "window-close";
        "Mod+R" = "spawn:noctalia msg panel-toggle launcher";
      };
    };
  };
}
```

Options:

| Option | Type | Default | Description |
|---|---|---|---|
| `enable` | bool | `false` | Enable Umbriel, a Wayland compositor built on wlroots and SceneFX |
| `package` | package | flake package | The Umbriel package to install |
| `settings` | attrset \| str \| path | `null` | Configuration written to `~/.config/umbriel/config.toml`. Leave null to use the packaged defaults. See `examples/config.toml` in the Umbriel repository for every available option |
| `validateConfig` | bool | `true` | Validate `settings` at build time (`umbriel validate`) |

> Note: the module disables nixpkgs' built-in `programs/wayland/umbriel.nix`.

## NixOS

### Noctalia (shell & bar)

```nix
{
  imports = [ inputs.noctalia.nixosModules.noctalia ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    # systemd.target = "hyprland-session.target";  # default: graphical-session.target
  };
}
```

Options:

| Option | Type | Default | Description |
|---|---|---|---|
| `enable` | bool | `false` | Enable Noctalia, a lightweight Wayland shell and bar |
| `package` | package | flake package | The Noctalia package to install system-wide |
| `systemd.enable` | bool | `false` | Provide a systemd user service for Noctalia |
| `systemd.target` | str | `graphical-session.target` | Systemd user target the service binds to |

### Umbriel (compositor + portal)

```nix
{
  imports = [ inputs.noctalia.nixosModules.umbriel ];

  programs.umbriel = {
    enable = true;
    # portalPackage is wired automatically; override only if needed
  };
}
```

Options:

| Option | Type | Default | Description |
|---|---|---|---|
| `enable` | bool | `false` | Enable Umbriel, a Wayland compositor built on wlroots and SceneFX |
| `package` | package | flake package | The Umbriel package to install |
| `portalPackage` | package | flake package | The `xdg-desktop-portal-umbriel` package to install |

Enabling Umbriel on NixOS:

- installs the compositor and registers an `umbriel` session with the display manager
- enables XDG desktop portals with the Umbriel backend when `portalPackage` is set

> Note: the module disables nixpkgs' built-in `programs/wayland/umbriel.nix`.

## Automation

- **Hourly updates**: [`update-packages.yml`](.github/workflows/update-packages.yml) refreshes `flake.lock`, opens a PR, builds all three packages, pushes results to Cachix, and auto-merges.
- **Dependabot**: keeps GitHub Actions up to date daily.

## Contributing

Issues and pull requests are welcome. When changing Nix code, make sure it formats cleanly (`nix fmt` / `nixfmt` style).

## License

Released under the [MIT License](LICENSE).
