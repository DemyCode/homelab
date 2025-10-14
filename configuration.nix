{
  modulesPath,
  lib,
  pkgs,
  ...
}:
let
  secrets = builtins.fromTOML (builtins.readFile ./secrets.toml);
  files = ./.;
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
  virtualisation.docker.enable = true;
  services.logind.lidSwitchExternalPower = "ignore";
  # packages
  environment.systemPackages =
    with pkgs;
    map lib.lowPrio [
      curl
      gitMinimal
      just
      nginx
      wireguard-tools
      docker
      docker-compose
      dysk
      ctop
    ];
  nix.gc.automatic = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  networking.firewall.enable = false;
  systemd.services.my-docker-compose = {
    script = ''
      mkdir -p /deployments
      echo "Syncing files to /deployments from ${files}"
      rsync -avP --delete --delete-excluded --filter=":- .gitignore" --exclude .git/ ${files}/ /deployments
      cd /deployments
      docker-compose -f docker-compose.yml -f docker-compose-lock.yml up --build --remove-orphans --detach --force-recreate
      docker system prune --all --force
    '';
    path = [
      pkgs.docker-compose
      pkgs.docker
      pkgs.rsync
    ];
    wantedBy = [ "multi-user.target" ];
    after = [
      "docker.service"
      "docker.socket"
    ];
    requires = [ "docker.service" ];
  };
  systemd.services.yolab-manager = {
    script = ''
      cd /deployments/yolab-manager
      nix run path:.
    '';
    path = [
      pkgs.nix
      pkgs.gitMinimal
    ];
    wantedBy = [ "multi-user.target" ];
    after = [
      "my-docker-compose.service"
    ];
    requires = [ "my-docker-compose.service" ];
  };
  system.stateVersion = "24.05";
}
