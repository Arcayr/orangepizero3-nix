{
  pkgs,
  buildUBoot,
}:
buildUBoot rec {
  version = "2021.07-sunxi";
  modDirVersion = "2021.07-sunxi";
  src = fetchGit {
    url = "https://github.com/orangepi-xunlong/u-boot-orangepi.git";
    ref = "v2021.07-sunxi";
    rev = "6fe17fac388aad17490cf386578b7532975e567f";
  };

  BL31 = "${pkgs.armTrustedFirmwareAllwinnerH616}/bl31.bin";
  defconfig = "orangepi_zero3_defconfig";
  filesToInstall = ["u-boot-sunxi-with-spl.bin"];
  extraMeta.platforms = ["aarch64-linux"];
}
