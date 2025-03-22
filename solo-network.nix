{ modulesPath, lib, pkgs, wireguard-mesh-coordinator, ... }:
let secrets = builtins.fromTOML (builtins.readFile ./secrets.toml);
in {
  # nixos anywhere
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  systemd.services.wireguard-mesh-coordinator-enter-network = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    description = "Enter the wireguard mesh network";
    serviceConfig = {
      User = "root";
      ExecStart =
        "${wireguard-mesh-coordinator.packages.x86_64-linux.default}/bin/wireguard-mesh-coordinator solo-network";
      Restart = "always";
      RestartSec = "5";
    };
  };
  system.stateVersion = "24.05";
}
