{
  stdenvNoCC,
  lib,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "uwe5622-firmware";
  version = "6.1.31-sun50iw9";

  compressFirmware = false;
  dontFixup = true;
  dontBuild = true;

  src = fetchGit {
    url = "https://github.com/orangepi-xunlong/firmware.git";
    ref = "master";
    rev = "b2809d6c7a79ab874a91b84b9b0d9169cb41a749";
  };

  installPhase = ''
    mkdir -p $out/lib/firmware
    cp -r . $out/lib/firmware
  '';

  meta = with lib; {
    description = "firmware for the uwe5622 from xunlong.";
    homepage = "https://github.com/orangepi-xunlong/firmware";
    license = licenses.unfreeRedistributableFirmware;
    platforms = ["aarch64-linux"];
  };
}
