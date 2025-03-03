{
  modulesPath,
  lib,
  pkgs,
  ...
}:
let
  secrets = builtins.fromTOML (builtins.readFile ./secrets.toml);
in
{
  # nixos anywhere
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./wireguard-manager.nix
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

  # packages
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.just
    pkgs.nginx
  ];

  # wireguard
  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 51820 ];
    allowedTCPPorts = [ 22 ];
  };
  networking.wireguard.enable = true;
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51820;
      privateKey = secrets.wireguard_private_key;
      peers = [
        { 
          publicKey = "GLuhgXc7jadJrKNJSjqcLXniDUiBw65cVtdCHAx92FI=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
      ];
    };
  };
  system.stateVersion = "24.05";
}
