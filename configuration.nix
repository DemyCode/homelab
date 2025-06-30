{ modulesPath, lib, pkgs, ... }:
let secrets = builtins.fromTOML (builtins.readFile ./secrets.toml);
in {
  # nixos anywhere
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    secrets.root_ssh
  ];
  services.logind.lidSwitchExternalPower = "ignore";
  # packages
  environment.systemPackages = with pkgs;
    map lib.lowPrio [ curl gitMinimal just nginx wireguard-tools ];

  system.stateVersion = "24.05";
}
