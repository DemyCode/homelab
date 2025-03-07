{
  modulesPath,
  lib,
  pkgs,
  wireguard-mesh-coordinator,
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
    pkgs.wireguard-tools
    wireguard-mesh-coordinator.packages.x86_64-linux.default
  ];

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 51820 ];
    allowedTCPPorts = [ 22 ];
  };
  networking.firewall.interfaces."wg0".allowedTCPPorts = [ 8000 ];
  systemd.services.wireguard-mesh-coordinator = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Start the wireguard mesh coordinator service";
      serviceConfig = {
        User = "root";
        ExecStart = ''${wireguard-mesh-coordinator.packages.x86_64-linux.default}/bin/wireguard-mesh-coordinator api''; 
        Restart = "always";
        RestartSec = "5";
      };
   };

  system.stateVersion = "24.05";
}
