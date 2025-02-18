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
        extraConfig =''
            proxy_ssl_server_name on;
            proxy_pass_header Authorization;
            client_max_body_size 512M;
            proxy_pass http://localhost:3000;
            proxy_set_header Connection $http_connection;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
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
