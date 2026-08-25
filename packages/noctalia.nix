{
  autoAddDriverRunpath,
  cairo,
  curl,
  fetchFromGitHub,
  fontconfig,
  freetype,
  git,
  glib,
  harfbuzz,
  installShellFiles,
  jemalloc,
  lib,
  libGL,
  libglvnd,
  libical,
  libjxl,
  libqalculate,
  librsvg,
  libsecret,
  libsndfile,
  libsodium,
  libwebp,
  libxkbcommon,
  libxml2,
  makeWrapper,
  md4c,
  meson,
  ninja,
  nlohmann_json,
  pam,
  pango,
  pipewire,
  pkg-config,
  polkit,
  sdbus-cpp_2,
  src,
  stb,
  stdenv,
  systemd,
  tomlplusplus,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wireplumber,
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

  stb' = stb.overrideAttrs (_: {
    version = "unstable-2025-10-26";
    src = fetchFromGitHub {
      owner = "nothings";
      repo = "stb";
      rev = "f1c79c02822848a9bed4315b12c8c8f3761e1296";
      hash = "sha256-BlyXJtAI7WqXCTT3ylww8zoG0hBxaojJnQDvdQOXJPE=";
    };
  });
in
stdenv.mkDerivation {
  pname = "noctalia";
  version = "unstable-${fmtDate src.lastModifiedDate}-${src.shortRev}";

  inherit src;

  postInstall = ''
    installShellCompletion --cmd noctalia \
      --bash <($out/bin/noctalia completions bash) \
      --fish <($out/bin/noctalia completions fish) \
      --zsh <($out/bin/noctalia completions zsh)
  '';

  postFixup = ''
    wrapProgram $out/bin/noctalia \
      --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  nativeBuildInputs = [
    autoAddDriverRunpath
    installShellFiles
    jemalloc
    makeWrapper
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    cairo
    curl
    fontconfig
    freetype
    glib
    harfbuzz
    libGL
    libglvnd
    libical
    libjxl
    libqalculate
    librsvg
    libsecret
    libsndfile
    libsodium
    libwebp
    libxkbcommon
    libxml2
    md4c
    nlohmann_json
    pam
    pango
    pipewire
    polkit
    sdbus-cpp_2
    stb'
    systemd
    tomlplusplus
    wayland
    wayland-protocols
    wireplumber
  ];

  mesonBuildType = "release";
  ninjaFlags = [ "-v" ];

  meta = with lib; {
    description = "A sleek, customizable desktop shell crafted for Wayland.";
    homepage = "https://github.com/noctalia-dev/noctalia";
    license = licenses.mit;
    mainProgram = "noctalia";
    platforms = platforms.linux;
  };
}
