{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # This pins requirements.txt provided by zephyr-nix.pythonEnv.
    zephyr.url = "github:zephyrproject-rtos/zephyr/v3.7.0";

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
          zephyrPyEnv = zephyr-nix.packages.${system}.pythonEnv;
          keymap_drawer = keymap_drawer-nix.packages.${system}.default;
        in {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              gcovr

              zephyrPyEnv
              (zephyr.sdk-0_16.override { targets = [ "arm-zephyr-eabi" ]; })

              cmake
              dtc
              ninja

              just
              yq # Make sure yq resolves to python-yq.
              tio
              #pkgs.svgexport

              # poetry build error
              keymap_drawer
              clang-tools
              #ctags

            ];

            shellHook = ''
              export Zephyr_DIR=$PWD/zmk_exts/zephyr/share/zephyr-package/cmake/
              export ZMK_BUILD_DIR=$PWD/.build
              export ZMK_SRC_DIR=$PWD/zmk_exts/zmk/app
            '';
          };
        });
    };
}
