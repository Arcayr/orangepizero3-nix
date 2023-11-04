{
  description = "Linux kernel and U-Boot for the Orange Pi Zero 3";
  inputs = {
    nixpkgs.url = "flake:nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    # tested on x86_64-linux only, no reason why other targets won't work though.
    system = "x86_64-linux";
    pkgs = (import nixpkgs {
      inherit system;
      crossSystem = "aarch64-linux";
      targetHost = "aarch64-linux";
    });

    aarch64Pkgs = (import nixpkgs {
      system = "aarch64-linux";
    });

  in
  {
    packages.aarch64-linux = import ./pkgs {inherit pkgs;};

    overlays.default = self: super: {
      linuxKernels.linuxOrangePiZero3 = self.packages.aarch64-linux.linuxOrangePiZero3;
      ubootOrangePiZero3 = self.packages.aarch64-linux.ubootOrangePiZero3;
    };

    devShells.x86_64-linux.default = pkgs.mkShell rec {
      nativeBuildInputs = with pkgs; [
        qemu
        gcc
        pkg-config
        ncurses
        bison
        bc
        flex
        elfutils
        binutils
        gdb
        openssl
        gnumake
        git
        buildPackages.ubootTools
      ];

      buildInputs = with aarch64Pkgs; [
        pkg-config
        ncurses
        openssl
        buildPackages.ubootTools
      ];

      shellHook = ''
      export ARCH=arm64;
      '';
    };
  };
}
