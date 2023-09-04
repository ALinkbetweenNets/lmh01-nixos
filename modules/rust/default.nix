{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lmh01.rust;
in
{

  options.lmh01.rust = {
    enable = mkEnableOption "activate rust toolchain";
  };

  config = mkIf cfg.enable {

    # TODO see if this is feasable or if it is a better idea to use rust using a nix shell
    # (i heared that it is a bad idea to install gcc directly this way)
    environment.systemPackages = with pkgs; [ cargo rustc clippy gcc ];

  };
}
