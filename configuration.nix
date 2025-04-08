{ modulesPath, lib, pkgs, wireguard-mesh-coordinator, ... }:
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

  # packages
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.just
    pkgs.nginx
    pkgs.wireguard-tools
    wireguard-mesh-coordinator.packages.x86_64-linux.default
    (pkgs.wrapHelm pkgs.kubernetes-helm {
      plugins = with pkgs.kubernetes-helmPlugins; [
        helm-secrets
        helm-diff
        helm-s3
        helm-git
      ];
    })
  ];

  networking.firewall.enable = false;
  networking.firewall.interfaces."wg0".allowedTCPPorts = [ 8000 ];

  system.stateVersion = "24.05";
}
