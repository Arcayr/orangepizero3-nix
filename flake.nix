{
  description = "linux kernel 6.1, u-boot 2021.07, and supporting firmware for the orange pi zero 3";
  inputs = {
    nixpkgs.url = "flake:nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    pkgs = import nixpkgs {system = "aarch64-linux";};
  in {
    formatter.x86_64-linux = pkgs.alejandra;
    formatter.aarch64-linux = pkgs.alejandra;
    packages.aarch64-linux = import ./pkgs {inherit pkgs;};
  };
}
