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
  version ? "git",
}:
stdenv.mkDerivation {
  pname = "xdg-desktop-portal-umbriel";
  inherit src version;

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
