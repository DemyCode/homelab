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
      mkdir -p /var/lib/ny-docker-compose
      cp ${./docker-compose.yml} /var/lib/my-docker-compose/docker-compose.yml
      cd /var/lib/my-docker-compose
      ${pkgs.docker-compose}/bin/docker-compose up --build --remove-orphans
    '';
    path = [ pkgs.docker-compose pkgs.docker ];
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" "docker.socket" ];
    requires = [ "docker.service" ];
    serviceConfig = {
      WorkingDirectory = "/var/lib/my-docker-compose";
      StateDirectory = "my-docker-compose";
    };
  };
  system.stateVersion = "24.05";
}
