{
  cairo,
  jemalloc,
  lcms2,
  lib,
  libdrm,
  libgbm,
  libGL,
  libinput,
  libxcb,
  libxcb-wm,
  libxkbcommon,
  makeBinaryWrapper,
  meson,
  ninja,
  nlohmann_json,
  pango,
  pixman,
  pkg-config,
  src,
  stdenv,
  tomlplusplus,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_20,
  xwayland-satellite,
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
  pname = "umbriel";
  version = "unstable-${fmtDate src.lastModifiedDate}-${src.shortRev}";

  inherit src;

  buildInputs = [
    cairo
    jemalloc
    lcms2
    libdrm
    libgbm
    libGL
    libinput
    libxcb
    libxcb-wm
    libxkbcommon
    nlohmann_json
    pango
    pixman
    tomlplusplus
    wayland
    wayland-protocols
    wlroots_0_20
  ];

  nativeBuildInputs = [
    makeBinaryWrapper
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  mesonBuildType = "release";
  mesonFlags = [ (lib.mesonEnable "tests" false) ];

  postInstall = ''
    substituteInPlace "$out/share/wayland-sessions/umbriel.desktop" \
      --replace-fail 'Exec=start-umbriel' "Exec=$out/bin/start-umbriel"

    wrapProgram $out/bin/umbriel \
      --prefix PATH : ${lib.makeBinPath [ xwayland-satellite ]} \
  '';

  passthru.providedSessions = [ "umbriel" ];

  meta = with lib; {
    description = "A Wayland compositor built on wlroots";
    homepage = "https://github.com/noctalia-dev/umbriel";
    license = licenses.mit;
    mainProgram = "umbriel";
    platforms = platforms.linux;
  };
}
