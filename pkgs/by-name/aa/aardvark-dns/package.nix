{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nixosTests,
}:

rustPlatform.buildRustPackage rec {
  pname = "aardvark-dns";
  version = "1.13.1";

  src = fetchFromGitHub {
    owner = "containers";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-VXuTHc/t+5QidTqMptoQqircHTtYzeEXfFFII8jeOrI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-ydvvV3w8VmfdSTXeJvMuN0oqkkZdWs6/9KocalRGWpg=";

  passthru.tests = { inherit (nixosTests) podman; };

  meta = with lib; {
    changelog = "https://github.com/containers/aardvark-dns/releases/tag/${src.rev}";
    description = "Authoritative dns server for A/AAAA container records";
    homepage = "https://github.com/containers/aardvark-dns";
    license = licenses.asl20;
    maintainers = with maintainers; [ ] ++ teams.podman.members;
    platforms = platforms.linux;
    mainProgram = "aardvark-dns";
  };
}
