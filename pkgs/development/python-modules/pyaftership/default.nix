{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pythonOlder,
  aiohttp,
  aresponses,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyaftership";
  version = "23.1.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "ludeeus";
    repo = "pyaftership";
    tag = version;
    hash = "sha256-njlDScmxIYWxB4EL9lOSGCXqZDzP999gI9EkpcZyFlE=";
  };

  propagatedBuildInputs = [ aiohttp ];

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytestCheckHook
  ];

  postPatch = ''
    # Upstream is releasing with the help of a CI to PyPI, GitHub releases
    # are not in their focus
    substituteInPlace setup.py \
      --replace 'version="main",' 'version="${version}",'
  '';

  pythonImportsCheck = [ "pyaftership" ];

  meta = with lib; {
    description = "Python wrapper package for the AfterShip API";
    homepage = "https://github.com/ludeeus/pyaftership";
    changelog = "https://github.com/ludeeus/pyaftership/releases/tag/${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ jamiemagee ];
  };
}
