# nix run .\#lollypops -- pi4b
{ self, ... }:
{ pkgs, lib, config, modulesPath, flake-self, home-manager, nixos-hardware, nixpkgs, ... }: {

  imports = [
    # being able to build the sd-image
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"

    # https://github.com/NixOS/nixos-hardware/tree/master/raspberry-pi/4
    nixos-hardware.nixosModules.raspberry-pi-4

    home-manager.nixosModules.home-manager

    self.nixosModules.server
    self.nixosModules.jellyfin
    self.nixosModules.restic
    self.nixosModules.wireguard
  ];

  ### build sd-image

  # nix build .\#nixosConfigurations.pi4b.config.system.build.sdImage
  # add boot.binfmt.emulatedSystems = [ "aarch64-linux" ]; to your x86 system
  # to build ARM stuff through qemu
  sdImage.compressImage = false;
  sdImage.imageBaseName = "raspi-image";

  # this workaround is currently needed to build the sd-image
  # basically: there currently is an issue that prevents the sd-image to be built successfully
  # remove this once the issue is fixed!
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
  ###

  lmh01 = {
    jellyfin.enable = true;
    options.type = "server";
    restic-client = {
      enable = true;
      backup-paths-lb = [
        "/home/louis/.secrets"
        "/home/louis/.ssh"
        "/home/louis/Obsidian"
      ];
      backup-paths-sn = [
        "/home/louis/.secrets"
        "/home/louis/.ssh"
        "/home/louis/HomeAssistant"
        "/home/louis/Obsidian"
      ];
      # stop home assistant before backup
      backup-prepare-sn = ''
        echo "Shutting down Home Assistant to perform backup"
        ${pkgs.docker}/bin/docker stop homeassistant
      '';
      backup-cleanup-sn = ''
        echo "Starting Home Assistant"
        ${pkgs.docker}/bin/docker start homeassistant
      '';
      # backup retry time is set to none, so that home assistant isn't offline, waiting for a backup
      backup-retry-time-sn = ''0m'';
    };
    wireguard.enable = true;
  };

  # Home Manager configuration
  home-manager = {
    # DON'T set useGlobalPackages! It's not necessary in newer
    # home-manager versions and does not work with configs using
    # nixpkgs.config
    useUserPackages = true;
    extraSpecialArgs = {
      inherit flake-self;
      # Pass system configuration (top-level "config") to home-manager modules,
      # so we can access it's values for conditional statements
      system-config = config;
    };
    users.louis = flake-self.homeConfigurations.server;
  };

  hardware.raspberry-pi."4".poe-hat.enable = true;
  networking.hostName = "pi4b-louis";

  networking.networkmanager.enable = true;

  networking.firewall.allowedTCPPorts = [
    8123 # used by home assistant
  ];

  lollypops.deployment = {
    local-evaluation = true;
    # ssh = { user = "root"; host = "<IP>"; };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

}
