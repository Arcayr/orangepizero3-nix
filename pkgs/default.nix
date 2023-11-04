{pkgs, ...}:
let
in {
  linuxOrangePiZero3 = pkgs.callPackage ./linux {};
  ubootOrangePiZero3 = pkgs.callPackage ./uboot {};
}
