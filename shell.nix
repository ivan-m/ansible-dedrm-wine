{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible
    cacert # For winetricks
    calibre # Need calibre-py2 as of 20.09
    dos2unix
    wine
    winetricks
    unzip
    xxd
    zip
  ];
}
