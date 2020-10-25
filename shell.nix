let
  pkgs = import <nixpkgs> {};
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible
    calibre
    wine
    winetricks
    unzip
  ];
}
