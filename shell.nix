let
  pkgs = import <nixpkgs> {};
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible
    wine
    winetricks
    unzip
  ];
}
