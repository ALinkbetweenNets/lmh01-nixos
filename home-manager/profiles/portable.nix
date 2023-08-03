{ config, pkgs, ... }: {

  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    _1password-gui
    alacritty
    discord
    dracula-theme
    beauty-line-icon-theme
    firefox
    font-awesome
    gitui
    hashcat
    kate
    neofetch
    nvtop
    signal-desktop
    tree
    unzip
    xclip
  ];

  programs = {
    git.enable = true;
    starship.enable = true;
    zoxide.enable = true;
    zsh.enable = true;
  };

  services = {
    flameshot.enable = true;
  };

  imports = [
    ../modules/git
    ../modules/zsh
  ];
}
