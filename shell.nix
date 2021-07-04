{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible
    cacert # For winetricks
    calibre
    dos2unix
    samba # winbind / ntlm_auth
    wine
    winetricks
    unzip
    xlsfonts # winetricks
    xxd
    zip
  ];
}
