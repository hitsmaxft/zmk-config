{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    # This pins requirements.txt provided by zephyr-nix.pythonEnv.
    #zephyr.url = "github:zmkfirmware/zephyr";
    zephyr.url = "github:zephyrproject-rtos/zephyr/v3.5.0";
    zephyr.flake = false;
    # zephyr.inputs.nixpkgs.follows = "nixpkgs";

    # Zephyr sdk and toolchain.
    #zephyr-nix.url = "github:urob/zephyr-nix";
    zephyr-nix.url = "github:adisbladis/zephyr-nix";
    zephyr-nix.inputs.zephyr.follows = "zephyr";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, zephyr-nix, ... }:
    let
      systems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          zephyr = zephyr-nix.packages.${system};
          keymap_drawer = pkgs.python3Packages.callPackage ./nix/keymap-drawer.nix { };
        in {
          default = pkgs.mkShellNoCC {
            packages = [
              pkgs.gcovr
              zephyr.pythonEnv
              (zephyr.sdk-0_16.override { targets = [ "arm-zephyr-eabi" ]; })

              pkgs.cmake
              pkgs.dtc
              pkgs.ninja

              pkgs.just
              pkgs.yq # Make sure yq resolves to python-yq.
              pkgs.tio

              # poetry build error
              keymap_drawer
              pkgs.clang-tools

              # -- Used by just_recipes and west_commands. Most systems already have them. --
              # pkgs.gawk
              # pkgs.unixtools.column
              # pkgs.coreutils # cp, cut, echo, mkdir, sort, tail, tee, uniq, wc
              # pkgs.diffutils
              # pkgs.findutils # find, xargs
              # pkgs.gnugrep
              # pkgs.gnused
            ];

            shellHook = ''
              export ZMK_BUILD_DIR=$(pwd)/.build;
              export ZMK_SRC_DIR=$(pwd)/zmk/app;
            '';
          };
        });
    };
}
