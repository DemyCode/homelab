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

  users.users.kubernetes = {
    isNormalUser = true;
    description = "kubernetes";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs;
      map lib.lowPrio [
        (pkgs.wrapHelm pkgs.kubernetes-helm {
          plugins = with pkgs.kubernetes-helmPlugins; [
            helm-secrets
            helm-diff
            helm-s3
            helm-git
          ];
        })
        wireguard-mesh-coordinator.packages.x86_64-linux.default
        pkgs.curl
        pkgs.gitMinimal
        pkgs.just
        pkgs.nginx
        pkgs.wireguard-tools
      ];
    openssh.authorizedKeys = [ secrets.kubernetes_ssh ];
  };

  # packages
  environment.systemPackages = [ ];

  system.stateVersion = "24.05";
}
