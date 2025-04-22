{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "keymap-drawer";
  version = "latest";

  src = pkgs.fetchFromGitHub {
    owner = "hitsmaxft";
    repo = "keymap-drawer";
    rev = "main";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with the actual hash
  };

  buildInputs = [ pkgs.nodejs ];

  buildPhase = ''
    npm install
    npm run build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r dist/* $out/bin/
  '';

  meta = with pkgs.lib; {
    description = "Keymap Drawer";
    homepage = "https://github.com/hitsmaxft/keymap-drawer";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}