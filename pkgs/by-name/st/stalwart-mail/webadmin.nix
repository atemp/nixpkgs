{
  lib,
  rustPlatform,
  fetchFromGitHub,
  trunk,
  tailwindcss_3,
  fetchNpmDeps,
  nix-update-script,
  nodejs,
  npmHooks,
  llvmPackages,
  wasm-bindgen-cli_0_2_93,
  binaryen,
  zip,
}:

rustPlatform.buildRustPackage rec {
  pname = "webadmin";
  version = "0.1.27";

  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "webadmin";
    tag = "v${version}";
    hash = "sha256-ts2FT4QWDqNmm9Qj6JWEhgFW+3jAK/w90WIKF1Vil/w=";
  };

  npmDeps = fetchNpmDeps {
    inherit src;
    name = "${pname}-npm-deps";
    hash = "sha256-na1HEueX8w7kuDp8LEtJ0nD1Yv39cyk6sEMpS1zix2s=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-cvXfX3hqIp4NAAT1DgO/XZOXkeOgIEwkigA01qGYnxA=";

  postPatch = ''
    # Using local tailwindcss for compilation
    substituteInPlace Trunk.toml --replace-fail "npx tailwindcss" "tailwindcss"
  '';

  nativeBuildInputs = [
    binaryen
    llvmPackages.bintools-unwrapped
    nodejs
    npmHooks.npmConfigHook
    tailwindcss_3
    trunk
    # needs to match with wasm-bindgen version in upstreams Cargo.lock
    wasm-bindgen-cli_0_2_93

    zip
  ];

  NODE_PATH = "$npmDeps";

  buildPhase = ''
    trunk build --offline --frozen --release
  '';

  installPhase = ''
    cd dist
    mkdir -p $out
    zip -r $out/webadmin.zip *
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Secure & modern all-in-one mail server Stalwart (webadmin module)";
    homepage = "https://github.com/stalwartlabs/webadmin";
    changelog = "https://github.com/stalwartlabs/webadmin/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ onny ];
  };
}
