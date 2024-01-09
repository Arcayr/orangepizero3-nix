{pkgs}: rec {
  linuxOrangePiZero3 = pkgs.callPackage ./linux {};
  ubootOrangePiZero3 = pkgs.callPackage ./uboot {};
  firmwareOrangePiZero3 = pkgs.callPackage ./firmware {};
}
