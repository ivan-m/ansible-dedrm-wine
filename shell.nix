let
  pkgs = import <nixpkgs> {};
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible
    calibre
    dos2unix
    wine
    winetricks
    unzip
    xxd
    zip
  ];
}
