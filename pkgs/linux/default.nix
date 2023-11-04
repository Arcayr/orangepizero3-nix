{pkgs, ...}:
(pkgs.linuxManualConfig rec {
  version = "6.1.31-sun50iw9";
  modDirVersion = "6.1.31";
  src = fetchGit {
    url = "https://github.com/orangepi-xunlong/linux-orangepi.git";
    ref = "orange-pi-6.1-sun50iw9";
    rev = "3495b5ee0594566c9fed930b96b1cae90600412e";
  };

  configfile = ./linux_sunxi64_defconfig;

  kernelPatches = [
    { name = "uwe5622-makefile-patch"; patch = ./uwe5622-Makefile.patch; }
    pkgs.linuxKernel.kernelPatches.bridge_stp_helper
    pkgs.linuxKernel.kernelPatches.request_key_helper
  ];

  allowImportFromDerivation = true;
  })
  .overrideAttrs (old: {
    name = "k"; # dodge uboot length limits
    nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.buildPackages.ubootTools ];
  })
