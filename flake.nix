{
  description = "Standalone tmux configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    tmux = import ./default.nix {inherit pkgs;};
  in {
    packages.${system} = {
      default = tmux.package;
      config = tmux.config;
    };
  };
}
