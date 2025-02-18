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
    pkgs.just
    pkgs.nginx
  ];
  services.nginx.package = pkgs.nginxStable.override { openssl = pkgs.libressl; };
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    # other Nginx options
    virtualHosts."git.mehdibektaoui.com" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;" +
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;"
          ;
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = secrets.acme_email;
  };
  users.users.gitea = {
    extraGroups  = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys  = [ secrets.gitea ];
  };
  services.gitea.enable = true;
  services.gitea.user = "gitea";
  services.gitea.settings.server.ROOT_URL = "https://git.mehdibektaoui.com/";
  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    secrets.root_ssh
  ];

  system.stateVersion = "24.05";
}
