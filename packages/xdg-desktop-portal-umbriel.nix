{
  cairo,
  gtk4,
  lib,
  libdrm,
  libgbm,
  meson,
  ninja,
  nlohmann_json,
  pipewire,
  pkg-config,
  sdbus-cpp_2,
  src,
  stdenv,
  systemd,
  tomlplusplus,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:
let
  fmtDate =
    raw:
    let
      year = builtins.substring 0 4 raw;
      month = builtins.substring 4 2 raw;
      day = builtins.substring 6 2 raw;
    in
    "${year}-${month}-${day}";
in
stdenv.mkDerivation {
  pname = "xdg-desktop-portal-umbriel";
  version = "unstable-${fmtDate src.lastModifiedDate}-${src.shortRev}";

  inherit src;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    cairo
    gtk4
    libdrm
    libgbm
    nlohmann_json
    pipewire
    sdbus-cpp_2
    systemd
    tomlplusplus
    wayland
    wayland-protocols
  ];

  mesonBuildType = "release";

  meta = with lib; {
    description = "xdg-desktop-portal backend for the Umbriel compositor";
    license = licenses.mit;
    mainProgram = "xdg-desktop-portal-umbriel";
    platforms = platforms.linux;
  };
}
