{
  cairo,
  gcc16Stdenv,
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
gcc16Stdenv.mkDerivation {
  pname = "xdg-desktop-portal-umbriel";
  version = "unstable-${fmtDate src.lastModifiedDate}-${src.shortRev}";

  inherit src;

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

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  mesonBuildType = "release";
  mesonFlags = [
    (lib.mesonOption "cpp_args" "-ffat-lto-objects")
    (lib.mesonOption "c_args" "-ffat-lto-objects")
    (lib.mesonBool "b_lto" true)
    (lib.mesonBool "strip" true)
  ];

  meta = with lib; {
    description = "xdg-desktop-portal backend for the Umbriel compositor";
    license = licenses.mit;
    mainProgram = "xdg-desktop-portal-umbriel";
    platforms = platforms.linux;
  };
}
