{pkgs, ...}:
pkgs.buildUBoot rec {
  version = "2021.07";
  modDirVersion = "2021.07";
  src = fetchGit {
    url = "https://github.com/orangepi-xunlong/u-boot-orangepi.git";
    ref = "v2021.07-sunxi";
    rev = "6fe17fac388aad17490cf386578b7532975e567f";
  };

  defconfig = "orangepi_zero3_defconfig";
  extraMeta.platforms = ["aarch64-linux"];
  BL31 = "${pkgs.armTrustedFirmwareAllwinnerH616}/bl31.bin";
  filesToInstall = ["u-boot-sunxi-with-spl.bin"];
}
