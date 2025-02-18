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
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 22 3000 ];
    allowedUDPPortRanges = [
      { from = 4000; to = 4007; }
      { from = 8000; to = 8010; }
    ];
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.gitea
    pkgs.just # for justfile
  ];
  users.users.gitea = {
    extraGroups  = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys  = [ secrets.gitea ];
  };
  services.gitea.enable = true;
  services.gitea.user = "gitea";
  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    secrets.root_ssh
  ];

  system.stateVersion = "24.05";
}
