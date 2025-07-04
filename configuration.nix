{ modulesPath, lib, pkgs, ... }:
let
  secrets = builtins.fromTOML (builtins.readFile ./secrets.toml);
  files = ./.;
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
  virtualisation.docker.enable = true;
  services.logind.lidSwitchExternalPower = "ignore";
  # packages
  environment.systemPackages = with pkgs;
    map lib.lowPrio [
      curl
      gitMinimal
      just
      nginx
      wireguard-tools
      docker
      docker-compose
    ];
  systemd.services.my-docker-compose = {
    script = ''
      rm -rf /deployments
      mkdir /deployments
      cp -r ${files}/* /deployments/
      docker-compose -f /deployments/docker-compose.yml up --build --remove-orphans --force-recreate 
    '';
    path = [ pkgs.docker-compose pkgs.docker ];
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" "docker.socket" ];
    requires = [ "docker.service" ];
  };
  system.stateVersion = "24.05";
}
