{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/e3e32b642a31e6714ec1b712de8c91a3352ce7e1";

    # This pins requirements.txt provided by zephyr-nix.pythonEnv.
    zephyr.url = "github:zmkfirmware/zephyr/v3.5.0+zmk-fixes";
    zephyr.flake = false;

    # Zephyr sdk and toolchain.
    zephyr-nix.url = "github:urob/zephyr-nix";
    zephyr-nix.inputs.zephyr.follows = "zephyr";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";

    keymap_drawer-nix = {
      url = "github:hitsmaxft/keymap-drawer";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, zephyr-nix, keymap_drawer-nix, ... }:
    let
      systems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {

      devShells = forAllSystems (system:
        let

          pkgs = nixpkgs.legacyPackages.${system};
          zephyr = zephyr-nix.packages.${system};
          keymap_drawer = keymap_drawer-nix.packages.${system}.default;
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
              #pkgs.svgexport

              # poetry build error
              keymap_drawer
              pkgs.clang-tools

            ];

            shellHook = ''
              export ZMK_BUILD_DIR=$PWD/.build
              export ZMK_SRC_DIR=$PWD/zmk/app
            '';
          };
        });
    };
}
